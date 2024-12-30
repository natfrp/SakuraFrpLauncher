#define AppName "SakuraFrp 启动器"
#define AppVersion ""
#define RealVersion GetVersionNumbersString("_publish\SakuraLibrary\SakuraLibrary.dll")

#define MainExecutable "SakuraLauncher.exe"

#define LibraryNameNet ".NET Framework 4.8"
#define LibraryNameWebView2 "Microsoft Edge WebView2 Runtime"

[Setup]
; Basics
AppId=SakuraFrpLauncher
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} v{#RealVersion}
AppCopyright=Copyright © iDea Leaper 2020-2024

AppMutex=Global\SakuraFrpService,SakuraFrpLauncher3,SakuraFrpLauncher3_Legacy

AppPublisher=SakuraFrp
AppPublisherURL=https://www.natfrp.com/
AppSupportURL=https://www.natfrp.com/

VersionInfoVersion={#RealVersion}

; Wizard
WizardStyle=modern
LicenseFile=LICENSE
ShowComponentSizes=yes
AlwaysShowDirOnReadyPage=yes
UninstallDisplayName={#AppName}
ArchitecturesAllowed=x86 x64 arm64
ArchitecturesInstallIn64BitMode=x64 arm64

DefaultDirName={autopf}\SakuraFrpLauncher
DefaultGroupName={#AppName}

DisableDirPage=yes
DisableProgramGroupPage=yes

; Output
OutputDir=bin
OutputBaseFilename=SakuraLauncher

; Compression
Compression=lzma2/ultra64
SolidCompression=yes
LZMANumBlockThreads=32
LZMAUseSeparateProcess=yes

[Languages]
Name: "ChineseSimplified"; MessagesFile: "compiler:Languages\ChineseSimplified.isl"

[Types]
Name: "default"; Description: "默认设置";
Name: "custom"; Description: "自定义"; Flags: iscustom;

[Components]
Name: "frpc"; Description: "frpc"; Types: default custom; Flags: fixed
Name: "frpc\x86"; Description: "frpc (32 位)"; Check: IsX86; Types: default custom; Flags: exclusive fixed
Name: "frpc\x64"; Description: "frpc (64 位)"; Check: IsX64; Types: default custom; Flags: exclusive fixed
Name: "frpc\arm64"; Description: "frpc (ARM64)"; Check: IsARM64; Types: default custom; Flags: exclusive fixed

Name: "launcher"; Description: "核心服务"; Types: default custom; Flags: fixed
Name: "launcher\x86"; Description: "核心服务 (32 位)"; Check: IsX86; Types: default custom; Flags: exclusive fixed
Name: "launcher\x64"; Description: "核心服务 (64 位)"; Check: IsX64; Types: default custom; Flags: exclusive fixed
Name: "launcher\arm64"; Description: "核心服务 (ARM64)"; Check: IsARM64; Types: default custom; Flags: exclusive fixed
Name: "launcher\service"; Description: "安装为系统服务"; Flags: dontinheritcheck
Name: "launcher\service\webui"; Description: "初始化 Web UI (仅限高级用户)"; Flags: dontinheritcheck

Name: "launcher_ui"; Description: "用户界面"; Types: default custom
Name: "launcher_ui\wpf"; Description: "WPF 界面"; Types: default; Flags: exclusive
Name: "launcher_ui\legacy"; Description: "经典界面 (不推荐)"; Types: custom; Flags: exclusive

Name: "wd_exclusion"; Description: "添加 Windows Defender 排除项"; Types: default; Flags: dontinheritcheck

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Components: "launcher_ui"; Flags: checkedonce

[Files]
Source: "_publish\sign\frpc_windows_386_gui.exe"; DestDir: "{app}"; DestName: "frpc.exe"; Flags: ignoreversion; Components: "frpc\x86"
Source: "_publish\sign\frpc_windows_386_gui.exe.sig"; DestDir: "{app}"; DestName: "frpc.exe.sig"; Flags: ignoreversion; Components: "frpc\x86"
Source: "_publish\sign\frpc_windows_amd64_gui.exe"; DestDir: "{app}"; DestName: "frpc.exe"; Flags: ignoreversion; Components: "frpc\x64"
Source: "_publish\sign\frpc_windows_amd64_gui.exe.sig"; DestDir: "{app}"; DestName: "frpc.exe.sig"; Flags: ignoreversion; Components: "frpc\x64"
Source: "_publish\sign\frpc_windows_arm64_gui.exe"; DestDir: "{app}"; DestName: "frpc.exe"; Flags: ignoreversion; Components: "frpc\arm64"
Source: "_publish\sign\frpc_windows_arm64_gui.exe.sig"; DestDir: "{app}"; DestName: "frpc.exe.sig"; Flags: ignoreversion; Components: "frpc\arm64"

Source: "_publish\sign\SakuraFrpService_386.exe"; DestDir: "{app}"; DestName: "SakuraFrpService.exe"; Flags: ignoreversion; Components: "launcher\x86"
Source: "_publish\sign\SakuraFrpService_386.exe.sig"; DestDir: "{app}"; DestName: "SakuraFrpService.exe.sig"; Flags: ignoreversion; Components: "launcher\x86"
Source: "_publish\sign\SakuraFrpService_amd64.exe"; DestDir: "{app}"; DestName: "SakuraFrpService.exe"; Flags: ignoreversion; Components: "launcher\x64"
Source: "_publish\sign\SakuraFrpService_amd64.exe.sig"; DestDir: "{app}"; DestName: "SakuraFrpService.exe.sig"; Flags: ignoreversion; Components: "launcher\x64"
Source: "_publish\sign\SakuraFrpService_arm64.exe"; DestDir: "{app}"; DestName: "SakuraFrpService.exe"; Flags: ignoreversion; Components: "launcher\arm64"
Source: "_publish\sign\SakuraFrpService_arm64.exe.sig"; DestDir: "{app}"; DestName: "SakuraFrpService.exe.sig"; Flags: ignoreversion; Components: "launcher\arm64"

Source: "_publish\SakuraLibrary\*"; DestDir: "{app}"; Flags: ignoreversion; Components: "launcher_ui"
Source: "_publish\SakuraLauncher\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs; Components: "launcher_ui\wpf"
Source: "_publish\LegacyLauncher\*"; DestDir: "{app}"; Flags: ignoreversion; Components: "launcher_ui\legacy"

[Icons]
; Start Menu
Name: "{group}\{#AppName}"; Filename: "{app}\SakuraLauncher.exe"; Components: "launcher_ui\wpf"
Name: "{group}\{#AppName}"; Filename: "{app}\LegacyLauncher.exe"; Components: "launcher_ui\legacy"

Name: "{group}\访问 SakuraFrp 管理面板"; Filename: "https://www.natfrp.com/user/"

Name: "{group}\{cm:UninstallProgram,{#AppName}}"; Filename: "{uninstallexe}"

; Desktop Icon
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\SakuraLauncher.exe"; Components: "launcher_ui\wpf"; Tasks: "desktopicon"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\LegacyLauncher.exe"; Components: "launcher_ui\legacy"; Tasks: "desktopicon"

[Run]
; Fix ACL
Filename: "{app}\SakuraFrpService.exe"; Parameters: "--fix-acl"; StatusMsg: "正在设置目录权限..."; Flags: runascurrentuser

; Service
Filename: "{app}\SakuraFrpService.exe"; Parameters: "--install"; StatusMsg: "正在安装系统服务..."; Components: "launcher\service"; Flags: runascurrentuser

; Post Install Actions
Filename: "{app}\SakuraLauncher.exe"; Description: "{cm:LaunchProgram,{#AppName}}"; Components: "launcher_ui\wpf"; Flags: nowait postinstall skipifsilent
Filename: "{app}\LegacyLauncher.exe"; Description: "{cm:LaunchProgram,{#AppName}}"; Components: "launcher_ui\legacy"; Flags: nowait postinstall skipifsilent

; WebUI
Filename: "{app}\SakuraFrpService.exe"; Description: "初始化 Web UI"; Components: "launcher\service\webui"; Flags: postinstall; Parameters: "webui --init"
Filename: "{sys}\sc.exe"; Description: "启动系统服务"; Components: "launcher\service"; Flags: postinstall runhidden; Parameters: "start SakuraFrpService"

[UninstallRun]
Filename: "{sys}\sc.exe"; Parameters: "stop SakuraFrpService"; RunOnceId: "RemoveService-Stop"; Flags: runhidden
Filename: "{app}\SakuraFrpService.exe"; Parameters: "--uninstall"; RunOnceId: "RemoveService-Uninstall"
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -Command Remove-MpPreference -ExclusionPath """"""""{app}"""""""", """"""""{app}\frpc.exe"""""""", """"""""$env:ProgramData\SakuraFrpService\Update"""""""", """"""""$env:ProgramData\SakuraFrpService"""""""""; Flags: runascurrentuser runhidden nowait; Components: "wd_exclusion"

[UninstallDelete]
; 2.0 service installation logs
Type: files; Name: "{app}\InstallUtil.InstallLog"
Type: files; Name: "{app}\SakuraFrpService.InstallLog"

; Possible update leftovers
Type: files; Name: "{app}\*.del"

Type: dirifempty; Name: "{app}"

[Code]
var
	requiresRestart: Boolean;
	downloadPage: TDownloadWizardPage;

	installNet: Boolean;
	installWebView2: Boolean;

function TryInstall(const Name, File, Args: String; const CheckResult: Boolean): String;
var
	resultCode: Integer;
	outputPage: TOutputProgressWizardPage;
begin
	outputPage := CreateOutputProgressPage('安装运行环境', '正在安装 ' + Name);
	outputPage.ProgressBar.Style := npbstMarquee;
	outputPage.ProgressBar.Visible := True;
	outputPage.Show;

	if not Exec(ExpandConstant('{tmp}\' + File), Args, '', SW_SHOW, ewWaitUntilTerminated, resultCode) then
		Result := Name + ' 安装失败: ' + SysErrorMessage(resultCode)
	else if CheckResult then
		case resultCode of
			0: ;
			1641, 3010: requiresRestart := True;
			else Result := Name + ' 安装失败: 错误代码 ' + IntToStr(resultCode);
		end;

	outputPage.Hide;
end;

function CompareVersion(const v1, v2: String): Integer;
var
	pv1, pv2: Int64;
begin
	if not StrToVersion(v1, pv1) then pv1 := 0;
	if not StrToVersion(v2, pv2) then pv2 := 0;

	Result := ComparePackedVersion(pv1, pv2);
end;

//// Install Events ///////////////////////////////////////////

procedure InitializeWizard;
var
	version: Cardinal;
	versionStr: String;
	verifyWebView2: Boolean;
begin
	downloadPage := CreateDownloadPage(SetupMessage(msgWizardPreparing), SetupMessage(msgPreparingDesc), nil);

	installNet := (not RegQueryDWordValue(HKLM, 'SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full', 'Release', version)) or (version < 528040);

	{ WebView2: https://stackoverflow.com/questions/72331206/detecting-if-webview2-runtime-is-installed-with-inno-setup }
	verifyWebView2 := false;
	if (IsWin64) then
	begin
		if (RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}', 'pv', versionStr)) then
			verifyWebView2 := true;
	end	else if (RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}', 'pv', versionStr)) then
		verifyWebView2 := true;

	if (not verifyWebView2) and (RegQueryStringValue(HKEY_CURRENT_USER, 'Software\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}', 'pv', versionStr)) then
		verifyWebView2 := true;

	installWebView2 := (not verifyWebView2) or (CompareVersion(versionStr, '104.0.1293.70') < 0)
end;

function UpdateReadyMemo(const Space, NewLine, MemoUserInfoInfo, MemoDirInfo, MemoTypeInfo, MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: String): String;
begin
	Result := '';

	if WizardIsComponentSelected('launcher_ui') and (installNet or installWebView2) then
	begin
		Result := Result + '运行环境 (需要联网下载):' + Newline;

		if installNet then
			Result := Result + Space + '{#LibraryNameNet}' + Newline;

		if installWebView2 then
			Result := Result + Space + '{#LibraryNameWebView2}' + Newline;

		Result := Result + NewLine;
	end;

	if MemoUserInfoInfo <> '' then
		Result := Result + MemoUserInfoInfo + Newline + NewLine;

	if MemoDirInfo <> '' then
		Result := Result + MemoDirInfo + Newline + NewLine;

	if MemoTypeInfo <> '' then
		Result := Result + MemoTypeInfo + Newline + NewLine;

	if MemoComponentsInfo <> '' then
		Result := Result + MemoComponentsInfo + Newline + NewLine;

	if MemoGroupInfo <> '' then
		Result := Result + MemoGroupInfo + Newline + NewLine;

	if MemoTasksInfo <> '' then
		Result := Result + MemoTasksInfo + Newline + NewLine;
end;

procedure ExitProcess(exitCode: Integer);
	external 'ExitProcess@kernel32.dll stdcall';

function Explode(Text: String; Separator: String): TArrayOfString;
var
	i, p: Integer;
begin
	i := 0;
	repeat
		SetArrayLength(Result, i + 1);
		p := Pos(Separator, Text);
		if p > 0 then begin
			Result[i] := Copy(Text, 1, p - 1);
			Text := Copy(Text, p + Length(Separator), Length(Text));
			i := i + 1;
		end else begin
			Result[i] := Text;
			Text := '';
		end;
	until Length(Text) = 0;
end;

function NextButtonClick(const CurPageID: Integer): Boolean;
var
	retry: Boolean;
	regVal: Cardinal;
	retCode: Integer;

	winHttpReq: Variant;
	links: TArrayOfString;
	i: Integer;

	dotnet48Found: Boolean;
	webview2Found: Boolean;
begin
	Result := True;
	if (CurPageID = wpSelectComponents) then begin
		if WizardIsComponentSelected('wd_exclusion') then begin
			if ((RegQueryDWordValue(HKLM, 'SOFTWARE\Policies\Microsoft\Windows Defender', 'DisableLocalAdminMerge', regVal)) and (regVal = 1)) then begin
				RegWriteDWordValue(HKLM, 'SOFTWARE\Policies\Microsoft\Windows Defender', 'DisableLocalAdminMerge', 0);
			end;
			if ((RegQueryDWordValue(HKLM, 'SYSTEM\CurrentControlSet\Services\SecurityHealthService', 'Start', regVal)) and (regVal = 4)) then begin
				if (SuppressibleMsgBox('检测到您禁用了 Windows 安全中心服务，这可能造成无法正确写入排除项，并导致 frpc 被删除'+#13#10+'如果您希望自动进行修复并重启，请点击"确定"，否则点击"取消"。自动修复将启用 Windows 安全中心服务'+#13#10#13#10+'【点击确定后电脑会重启，请先保存所有未保存的文件】'+#13#10+'【点击确定后电脑会重启，请先保存所有未保存的文件】'+#13#10+'【点击确定后电脑会重启，请先保存所有未保存的文件】', mbError, MB_OKCANCEL, IDCANCEL) = IDOK) then begin
					RegWriteDWordValue(HKLM, 'SYSTEM\CurrentControlSet\Services\SecurityHealthService', 'Start', 2);
					Exec('>', 'shutdown /r /t 3 /c "即将重启以启用安全中心服务"', '', SW_SHOWNORMAL, ewWaitUntilTerminated, retCode);
					ExitProcess(0);
				end;
			end;
		end;
		if not WizardIsComponentSelected('launcher_ui') then begin
			if WizardIsComponentSelected('launcher\service\webui') then
				Result := SuppressibleMsgBox('您选择了不使用原生界面、只启用 Web UI, Web UI 仅推荐高级用户使用'+#13#10+'请确认您理解此选择的含义和 Web UI 的配置方法, 否则请勾选一个 "用户界面"', mbError, MB_OKCANCEL, IDCANCEL) = IDOK
			else begin
				SuppressibleMsgBox('请至少选择一个用户界面', mbError, MB_OK, IDOK);
				Result := False;
			end;
		end;
	end else if (CurPageID = wpReady) and WizardIsComponentSelected('launcher_ui') and (installNet or installWebView2) then begin
		winHttpReq := CreateOleObject('WinHttp.WinHttpRequest.5.1');
		winHttpReq.Open('GET', 'https://nya.globalslb.net/natfrp/client/launcher-windows/runtime.txt', False);
		winHttpReq.Send;

		if winHttpReq.Status <> 200 then begin
			SuppressibleMsgBox('无法获取运行时下载链接，请检查网络连接', mbError, MB_OK, IDOK);
			Result := False;
			Exit;
		end;

		downloadPage.Clear;

		links := Explode(winHttpReq.ResponseText, #10);
		i := 0;
		while i < GetArrayLength(links) do begin
			case links[i] of
				'{#LibraryNameNet}': begin
					if Pos('https://download.visualstudio.microsoft.com/', links[i + 1]) <> 1 then begin
						SuppressibleMsgBox('获取到的 .NET Framework 4.8 下载链接无效, 请尝试重新下载安装包或联系我们' + #13#10 + links[i + 1], mbError, MB_OK, IDOK);
						Result := False;
						Exit;
					end;
					if installNet then
						downloadPage.Add(links[i + 1], 'dotnet.exe', links[i + 2]);
					dotnet48Found := True;
				end;
				'{#LibraryNameWebView2}': begin
					if Pos('https://msedge.sf.dl.delivery.mp.microsoft.com/', links[i + 1]) <> 1 then begin
						SuppressibleMsgBox('获取到的 WebView2 下载链接无效, 请尝试重新下载安装包或联系我们' + #13#10#13#10 + links[i + 1], mbError, MB_OK, IDOK);
						Result := False;
						Exit;
					end;
					if installWebView2 then
						downloadPage.Add(links[i + 1], 'MicrosoftEdgeWebview2Setup.exe', links[i + 2]);
					webview2Found := True;
				end;
			end;
			i := i + 4;
		end;

		if (installNet and not dotnet48Found) or (installWebView2 and not webview2Found) then begin
			SuppressibleMsgBox('无法获取部分组件的下载链接, 请检查网络连接、尝试重新下载安装包或联系我们' + #13#10#13#10 + winHttpReq.ResponseText, mbError, MB_OK, IDOK);
			Result := False;
			Exit;
		end;

		downloadPage.Show;
		try
			retry := True;
			while retry do begin
				retry := False;
				try
					downloadPage.Download;
				except
					if GetExceptionMessage = SetupMessage(msgErrorDownloadAborted) then
						Result := False
					else case SuppressibleMsgBox(AddPeriod(GetExceptionMessage), mbError, MB_RETRYCANCEL, IDCANCEL) of
						IDRETRY: retry := True;
						IDCANCEL: Result := False;
					end;
				end;
			end;
		finally
			downloadPage.Hide;
		end;
	end;
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
var
	resultCode: Integer;
begin
	if WizardIsComponentSelected('launcher_ui') then
	begin
		if installNet then
			Result := Result + TryInstall('{#LibraryNameNet}', 'dotnet.exe', '/passive /norestart /showrmui /showfinalerror', true);

		if installWebView2 then
			Result := Result + TryInstall('{#LibraryNameWebView2}', 'MicrosoftEdgeWebview2Setup.exe', '/install', false);
	end;
	if WizardIsComponentSelected('wd_exclusion') then
		Exec('powershell.exe', '-ExecutionPolicy Bypass -Command Add-MpPreference -ExclusionPath """"' + ExpandConstant('{app}') + '"""", """"$env:ProgramData\SakuraFrpService""""', '', SW_HIDE, ewWaitUntilTerminated, resultCode);
end;

function NeedRestart(): Boolean;
begin
	Result := requiresRestart;
end;

//// Uninstall Events ///////////////////////////////////////////

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
	if (CurUninstallStep = usPostUninstall) and (MsgBox('是否删除启动器配置文件? 下列文件夹将会被删除: '
		+#13#10+'	%LocalAppData%\SakuraLauncher'
		+#13#10+'	%LocalAppData%\LegacyLauncher'
		+#13#10+'	%LocalAppData%\SakuraFrpService'
		+#13#10+'	%ProgramData%\SakuraFrpService', mbConfirmation, MB_YESNO or MB_DEFBUTTON2) = IDYES) then
	begin
		DelTree(ExpandConstant('{localappdata}\SakuraLauncher'), True, True, True);
		DelTree(ExpandConstant('{localappdata}\LegacyLauncher'), True, True, True);
		DelTree(ExpandConstant('{localappdata}\SakuraFrpService'), True, True, True);
		DelTree(ExpandConstant('{commonappdata}\SakuraFrpService'), True, True, True);
	end;
end;
