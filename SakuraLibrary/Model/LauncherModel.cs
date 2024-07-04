﻿using Grpc.Core;
using Grpc.Net.Client;
using SakuraLibrary.Helper;
using SakuraLibrary.Proto;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Diagnostics;
using System.IO.Pipes;
using System.Linq;
using System.Net.Http;
using System.Reflection;
using System.Threading;
using System.Threading.Tasks;
using NatfrpServiceClient = SakuraLibrary.Proto.NatfrpService.NatfrpServiceClient;
using UserStatus = SakuraLibrary.Proto.User.Types.Status;

namespace SakuraLibrary.Model
{
    public abstract class LauncherModel : ModelBase
    {
        static LauncherModel()
        {
            AppContext.SetSwitch("System.Net.Http.SocketsHttpHandler.Http2Support", true);
            AppContext.SetSwitch("System.Net.Http.SocketsHttpHandler.Http2UnencryptedSupport", true);
        }

        public static Empty RpcEmpty = new();

        public readonly NatfrpServiceClient RPC = new(GrpcChannel.ForAddress("http://localhost", new GrpcChannelOptions
        {
            HttpHandler = new StandardSocketsHttpHandler()
            {
                UseProxy = false,
                ConnectCallback = async (context, cancellationToken) =>
                {
                    var pipe = new NamedPipeClientStream(".", Consts.PipeName, PipeDirection.InOut, PipeOptions.Asynchronous);
                    try
                    {
                        await pipe.ConnectAsync(cancellationToken);
                    }
                    catch
                    {
                        pipe.Dispose();
                    }
                    return pipe;
                }
            }
        }));
        public readonly DaemonHost Daemon;

        public readonly CancellationTokenSource CTS = new();

        public LauncherModel(bool forceDaemon = false)
        {
            Daemon = new DaemonHost(this, forceDaemon);
        }

        protected async void Run()
        {
            Daemon.Start();

            while (!CTS.IsCancellationRequested)
            {
                try
                {
                    var tasks = new Task[]
                    {
                        await RPC.StreamUpdate(RpcEmpty).InitStream(u =>
                        {
                            if (u.User != null)
                            {
                                var us = UserInfo.Status != u.User.Status;
                                UserInfo = u.User;
                                // Make sure the SwitchTab don't get triggered by mistake
                                if (us)
                                {
                                    Dispatcher.Invoke(() => RaisePropertyChanged("_Login_State"));
                                }
                            }
                            if (u.Nodes != null) Nodes = u.Nodes.Nodes;
                            if (u.Config != null) Config = u.Config;
                            if (u.Update != null) Update = u.Update;
                            if (u.Notifications != null) Notifications = u.Notifications.Notifications;
                        }, CTS.Token),
                        await RPC.StreamLog(RpcEmpty).InitStream(l =>
                        {
                            if (l.Category != Proto.Log.Types.Category.Unknown)
                            {
                                 Dispatcher.Invoke(() => Log(l));
                            }
                        }, CTS.Token),
                        await RPC.StreamTunnels(RpcEmpty).InitStream(t => Dispatcher.Invoke(() =>
                        {
                            switch(t.Action)
                            {
                            case TunnelUpdate.Types.Action.Unknown: // dummy update
                                break;
                            case TunnelUpdate.Types.Action.Add:
                                Tunnels.Add(new TunnelModel(t.Tunnel, this));
                                break;
                            case TunnelUpdate.Types.Action.Update:
                                var find = Tunnels.FirstOrDefault(x => x.Id == t.Tunnel.Id);
                                if (find != null)
                                {
                                    find.Proto = t.Tunnel;
                                }
                                break;
                            case TunnelUpdate.Types.Action.Delete:
                                Tunnels.Remove(Tunnels.FirstOrDefault(x => x.Id == t.Tunnel.Id));
                                break;
                            case TunnelUpdate.Types.Action.Clear:
                                Tunnels.Clear();
                                break;
                            }
                        }), CTS.Token),
                    };

                    Connected = true;

                    await Task.WhenAll(tasks);
                }
                catch (Exception ex)
                {
                    Connected = false;
                    Console.WriteLine(ex);
                }

                // In case of disconnect, reset UI state
                UserInfo = new User();
                Config = new ServiceConfig();
                Update = new SoftwareUpdate();
                Dispatcher.Invoke(() =>
                {
                    Nodes.Clear();
                    Tunnels.Clear();
                    ClearLog();
                });
                await Task.Delay(1000);
            }
        }

        #region ViewModel Abstraction

        // Same as MessageBox Win32 API
        public enum MessageMode : uint
        {
            Ok = 0,
            OkCancel = 1,
            AbortRetryIgnore = 2,

            Error = 0x10,
            Confirm = 0x20,
            Warning = 0x30,
            Info = 0x40,
        }

        public enum MessageResult : int
        {
            Ok = 1,
            Cancel = 2,
            Abort = 3,
            Retry = 4,
            Ignore = 5,
        }

        /// <summary>Must be called with <see cref="DispatcherWrapper"/></summary>
        public abstract void Log(Log l, bool init = false);

        /// <summary>Must be called with <see cref="DispatcherWrapper"/></summary>
        public abstract void ClearLog();

        public abstract IntPtr GetHwnd();

        #endregion

        #region Main Window

        public MessageResult ShowMessage(string message, string title, MessageMode mode) => (MessageResult)NTAPI.MessageBox(GetHwnd(), message, title, (uint)mode);

        public bool Connected { get => _connected; set => Set(out _connected, value); }
        private bool _connected = false;

        public User UserInfo { get => _userInfo; set => SafeSet(out _userInfo, value ?? new User()); }
        private User _userInfo = new();

        public IDictionary<int, Node> Nodes { get => _nodes; set => SafeSet(out _nodes, value); }
        private IDictionary<int, Node> _nodes = new Dictionary<int, Node>();

        public IList<Notification> Notifications { get => _notifications; set => SafeSet(out _notifications, value); }
        private IList<Notification> _notifications = new List<Notification>();

        public ObservableCollection<TunnelModel> Tunnels { get; set; } = new ObservableCollection<TunnelModel>();

        public void ShowError(Exception e, string title = "操作失败")
        {
            string msg = "";
            if (e is AggregateException ae)
            {
                foreach (var ie in ae.InnerExceptions)
                {
                    if (ie is RpcException)
                    {
                        e = ie;
                        break;
                    }
                }
            }
            if (e is RpcException re)
            {
                if (re.Status.StatusCode != StatusCode.Unknown)
                {
                    msg += $"[{re.Status.StatusCode}] ";
                }
                msg += re.Status.Detail;
            }
            else
            {
                msg = e.ToString();
            }
            ShowMessage(msg, title, MessageMode.Error);
        }

        #endregion

        #region Generic RPC

        public async Task RequestReloadNodesAsync(bool force = true) => await RPC.ReloadNodesAsync(new() { Force = force });

        public async Task RequestReloadTunnelsAsync() => await RPC.ReloadTunnelsAsync(RpcEmpty);

        public Task<TunnelUpdate> RequestCreateTunnelAsync(string localIp, int localPort, string name, string note, string type, int remote, int node) => RequestCreateTunnelAsync(new Tunnel()
        {
            Name = name,
            Note = note,
            Node = node,
            Type = type,
            Remote = remote.ToString(),
            LocalIp = localIp,
            LocalPort = localPort,
        });

        public async Task<TunnelUpdate> RequestCreateTunnelAsync(Tunnel payload, TunnelUpdate.Types.Action action = TunnelUpdate.Types.Action.Add) => await RPC.UpdateTunnelAsync(new TunnelUpdate()
        {
            Action = action,
            Tunnel = payload,
        });

        public async Task RequestDeleteTunnelAsync(int id)
        {
            try
            {
                await RPC.UpdateTunnelAsync(new TunnelUpdate()
                {
                    Action = TunnelUpdate.Types.Action.Delete,
                    Tunnel = new Tunnel() { Id = id }
                });
            }
            catch (Exception ex)
            {
                ShowError(ex, "删除失败");
            }
        }

        public void RequestClearLog()
        {
            RPC.ClearLog(RpcEmpty);
            Dispatcher.Invoke(ClearLog);
        }

        public void RequestOpenCWD()
        {
            try
            {
                RPC.OpenCWD(RpcEmpty);
            }
            catch (Exception e)
            {
                ShowError(e);
            }
        }

        #endregion

        #region Settings - User Status

        [SourceBinding(nameof(UserInfo))]
        public string UserToken { get => UserInfo.Status != UserStatus.NoLogin ? "****************" : _userToken; set => SafeSet(out _userToken, value); }
        private string _userToken = "";

        [SourceBinding(nameof(UserInfo))]
        public bool LoggedIn => UserInfo.Status == UserStatus.LoggedIn;

        [SourceBinding(nameof(LoggingIn), nameof(LoggedIn), nameof(Connected))]
        public bool TokenEditable => Connected && !LoggingIn && !LoggedIn;

        [SourceBinding(nameof(UserInfo))]
        public bool LoggingIn { get => _loggingIn || UserInfo.Status == UserStatus.Pending; set => SafeSet(out _loggingIn, value); }
        private bool _loggingIn;

        public async Task LoginOrLogout()
        {
            LoggingIn = true;
            try
            {
                if (LoggedIn)
                {
                    await RPC.LogoutAsync(RpcEmpty).ConfigureAwait(false);
                }
                else
                {
                    await RPC.LoginAsync(new LoginRequest() { Token = UserToken }).ConfigureAwait(false);
                }
            }
            catch (Exception ex)
            {
                ShowError(ex, "登录失败");
            }
            finally
            {
                LoggingIn = false;
            }
        }

        #endregion

        #region Settings - Launcher

        // TODO: This should be moved to VM implementation

        /// <summary>
        /// 0 = Show all
        /// 1 = Suppress all
        /// 2 = Suppress INFO
        /// </summary>
        public int NotificationMode { get => _notificationMode; set => Set(out _notificationMode, value); }
        private int _notificationMode;

        public bool LogTextWrapping { get => _logTextWrapping; set => Set(out _logTextWrapping, value); }
        private bool _logTextWrapping;

        #endregion

        #region Settings - Service

        public ServiceConfig Config { get => _config; set => SafeSet(out _config, value); }
        private ServiceConfig _config = new();

        [SourceBinding(nameof(Config))]
        public bool BypassProxy
        {
            get => Config != null && Config.BypassProxy;
            set
            {
                if (Config != null)
                {
                    Config.BypassProxy = value;
                    PushServiceConfig();
                }
            }
        }

        [SourceBinding(nameof(Config))]
        public bool RemoteManagement
        {
            get => Config?.RemoteManagement ?? false;
            set
            {
                if (Config == null) return;
                Config.RemoteManagement = value && !string.IsNullOrEmpty(Config.RemoteManagementKey);
                PushServiceConfig();
            }
        }

        [SourceBinding(nameof(Config), nameof(LoggedIn))]
        public bool CanEnableRemoteManagement => LoggedIn && !string.IsNullOrEmpty(Config?.RemoteManagementKey);

        [SourceBinding(nameof(Config))]
        public bool EnableTLS
        {
            get => Config?.FrpcForceTls ?? false;
            set
            {
                if (Config == null) return;
                Config.FrpcForceTls = value;
                PushServiceConfig();
            }
        }

        [SourceBinding(nameof(Config))]
        public bool CheckUpdate
        {
            get => Config != null && Config.UpdateInterval != -1;
            set
            {
                if (Config != null)
                {
                    Config.UpdateInterval = value ? 86400 : -1;
                    PushServiceConfig();
                }
                RaisePropertyChanged();
            }
        }

        [SourceBinding(nameof(Config))]
        public string FrpcLogLevel
        {
            get => Config?.FrpcLogLevel ?? "";
            set
            {
                if (Config != null)
                {
                    Config.FrpcLogLevel = value;
                    PushServiceConfig();
                }
            }
        }

        public void PushServiceConfig(bool blocking = false)
        {
            if (blocking)
            {
                RPC.UpdateConfig(Config);
            }
            else
            {
                _ = RPC.UpdateConfigAsync(Config);
            }
        }

        #endregion

        #region Settings - Auto Update

        public string License => Properties.Resources.LICENSE;

        public string LauncherVersion => Assembly.GetExecutingAssembly().GetName().Version.ToString();

        public SoftwareUpdate Update { get => _update; set => SafeSet(out _update, value); }
        private SoftwareUpdate _update = new();

        [SourceBinding(nameof(Update))]
        public string ServiceVersion => Update.ServiceVersion ?? "-";

        [SourceBinding(nameof(Update))]
        public string FrpcVersion => Update.FrpcVersion ?? "-";

        [SourceBinding(nameof(Update))]
        public bool HaveUpdate => Update.Status == SoftwareUpdate.Types.Status.Downloading || Update.Status == SoftwareUpdate.Types.Status.Ready;

        [SourceBinding(nameof(CheckUpdate), nameof(Connected))]
        public bool CanCheckUpdate => Connected && CheckUpdate;

        [SourceBinding(nameof(Update))]
        public string UpdateText =>
            Update.Status == SoftwareUpdate.Types.Status.Downloading ? ("下载更新中... " + Math.Round(Update.DownloadCompleted / 1048576f, 2) + " MiB/" + Math.Round(Update.DownloadTotal / 1048576f, 2) + " MiB") :
            Update.Status != SoftwareUpdate.Types.Status.Ready ? "" :
            Update.UpdateUrl != "" ? "有更新可用, 点击此处打开下载页面" :
            "更新准备完成, 点此进行更新";

        public async Task<SoftwareUpdate> RequestCheckUpdateAsync() => await RPC.CheckUpdateAsync(RpcEmpty).ConfigureAwait(false);

        public void ConfirmUpdate()
        {
            if (Update.Status != SoftwareUpdate.Types.Status.Ready || ShowMessage(Update.ReleaseNote, "更新日志", MessageMode.OkCancel | MessageMode.Confirm) != MessageResult.Ok)
            {
                return;
            }
            if (Update.UpdateUrl != "")
            {
                Process.Start(Update.UpdateUrl);
                return;
            }
            if (NTAPI.GetSystemMetrics(SystemMetric.SM_REMOTESESSION) != 0 && ShowMessage("检测到当前正在使用远程桌面连接，若您正在通过 SakuraFrp 连接计算机，请勿进行更新\n进行更新时启动器和所有 frpc 将彻底退出并且需要手动确认操作，这会造成远程桌面断开并且无法恢复\n是否继续?", "警告", MessageMode.OkCancel | MessageMode.Warning) != MessageResult.Ok)
            {
                return;
            }
            try
            {
                RPC.ConfirmUpdate(RpcEmpty);
                Environment.Exit(0);
            }
            catch (Exception e)
            {
                ShowMessage(e.Message, "更新失败", MessageMode.Error);
            }
        }

        #endregion

        #region Settings - Working Mode

        public bool IsDaemon => Daemon.Daemon;

        [SourceBinding(nameof(IsDaemon))]
        public string WorkingMode => Daemon.Daemon ? "守护进程" : "系统服务";

        public bool SwitchingMode { get => _switchingMode; set => SafeSet(out _switchingMode, value); }
        private bool _switchingMode;

        public void SwitchWorkingMode()
        {
            if (SwitchingMode)
            {
                return;
            }
            if (ShowMessage("确定要切换运行模式吗? 切换运行模式时会安装 / 卸载系统服务, 请在弹出的 UAC 弹窗中点击 \"是\"", "操作确认", MessageMode.OkCancel | MessageMode.Confirm) != MessageResult.Ok)
            {
                return;
            }
            SwitchingMode = true;
            ThreadPool.QueueUserWorkItem(s =>
            {
                try
                {
                    Daemon.Stop();

                    var result = Daemon.SwitchMode();

                    Dispatcher.Invoke(() => RaisePropertyChanged(nameof(IsDaemon)));
                    Daemon.Start();
                }
                catch (Exception ex)
                {
                    ShowError(ex, "错误");
                }
                finally
                {
                    SwitchingMode = false;
                }
            });
        }

        #endregion
    }
}
