'
'	MediaMonkey Script
'	Name: silencebetweensongs
'	[silencebetweensongs]
'	Filename=silencebetweensongs.vbs
'	Description=(OBSOLETE, Use Cortina plugin instead) Add silence between songs
'	Language=VBScript
'	ScriptType=0 Auto Script

'	silencebetweensongs.vbs is copied to scripts\auto
'	Use  Tools/Options/Silence between songs  to set options.
'	--------------------------------------------------------------------	
'	This program is free software: you can redistribute it and/or modify
'	it under the terms of the GNU General Public License as published by
'	the Free Software Foundation, either version 3 of the License, or
'	(at your option) any later version.
'
'	This program is distributed in the hope that it will be useful,
'	but WITHOUT ANY WARRANTY; without even the implied warranty of
'	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
'	GNU General Public License for more details.
'
'	You should have received a copy of the GNU General Public License
'	along with this program.  If not, see <http://www.gnu.org/licenses/>.
'
Option Explicit

Const DEFAULTCustomFieldText = "[Gapless]"
Dim SilenceTime : SilenceTime = 3
Dim SilenceEnabled : SilenceEnabled = False
Dim isGapless : isGapless = False
Dim GapProgress : Set GapProgress = Nothing
Dim GapTimer : Set GapTimer = Nothing
Dim CurrentTrack : CurrentTrack = 0
Dim ExcludeGapless : ExcludeGapless = False
Dim CustomFieldToUse : CustomFieldToUse = 3
Dim CustomFieldText : CustomFieldText = DEFAULTCustomFieldText

Dim AppTitle : AppTitle = "SilenceBetweenSongs"
Dim cVersion : cVersion = "5.0.0.0"
Dim MenuItem : Set MenuItem = Nothing

'---------------------
Sub OnStartup
   '**** Do nothing, this plugin is obsolete
   'InitButton
   'InitTimer
   'SilenceBetweenSongs

   '**** Display obsolescence message
   Dim MsgObsolete
   MsgObsolete = "SilenceBetweenSongs is no longer maintained and no longer works." & vbNewLine & _
                 "Uninstall the SilenceBetweenSongs to stop seeing this message." & vbNewLine & vbNewLine & _
                 "Please use the Cortina plugin to add silence between songs." & vbNewLine & vbNewLine & _
                 "https://www.tangoexchange.com/versions/cortina.mmip"

   Call MsgBox(MsgObsolete, vbOkOnly + vbSystemModal)
End Sub
'---------------------
Sub InitButton()
	Dim Reg : Set Reg = SDB.Registry
	If Reg.OpenKey(AppTitle, True) Then
		
		If Not Reg.ValueExists("Version") Then
			Reg.StringValue("Version") = cVersion
		End If

		If Not Reg.ValueExists("Enabled") Then
			Reg.StringValue("Enabled") = SilenceEnabled
		End If

		If Not Reg.ValueExists("SilenceTime") Then
			Reg.StringValue("SilenceTime") = SilenceTime
		End If

		If Not Reg.ValueExists("CrossfadeState") Then
			Reg.StringValue("CrossfadeState") = SDB.Player.IsCrossfade
		End If

		If Not Reg.ValueExists("ExcludeGapless") Then
			Reg.BoolValue("ExcludeGapless") = ExcludeGapless
		End If

		If Not Reg.ValueExists("CustomFieldToUse") Then
			Reg.StringValue("CustomFieldToUse") = CustomFieldToUse
		End If

		If Not Reg.ValueExists("CustomFieldText") Then
			Reg.StringValue("CustomFieldText") = CustomFieldText
		End If


		SilenceTime = Reg.StringValue("SilenceTime")
		SilenceEnabled = Reg.BoolValue("Enabled")
		ExcludeGapless = Reg.BoolValue("ExcludeGapless")
		CustomFieldToUse = Reg.StringValue("CustomFieldToUse")
		CustomFieldText = Reg.StringValue("CustomFieldText")
		Reg.CloseKey
	End If
        
	Set MenuItem = SDB.UI.AddMenuItem(SDB.UI.Menu_Play,4,2)
	MenuItem.Caption = "Silence between songs"
	Script.RegisterEvent MenuItem, "OnClick", "ToggleSilence"
	MenuItem.Visible = True
	MenuItem.Checked = SilenceEnabled

	' Child of [Player] in the options:
	SDB.UI.AddOptionSheet "Silence between songs", Script.ScriptPath, "InitSheet", "SaveSheet", -2
End Sub

'---------------------
Sub ToggleSilence(p)   
	Dim Reg : Set Reg = SDB.Registry
	If Reg.OpenKey(AppTitle, True) Then
		SilenceEnabled = Not SilenceEnabled
		MenuItem.Checked = SilenceEnabled

		Reg.BoolValue("Enabled") = SilenceEnabled
	
		If SilenceEnabled then
			Reg.BoolValue("CrossfadeState") = SDB.Player.IsCrossfade
			SDB.Player.IsCrossfade = False
		Else
			SDB.Player.IsCrossfade = Reg.BoolValue("CrossfadeState")
		End If
		Reg.CloseKey
		SilenceBetweenSongs
	End If
End Sub

'---------------------
Sub SilenceBetweenSongs
    If SilenceEnabled Then
       Script.RegisterEvent SDB, "OnPlay", "PlayerOnPlay"
       Script.RegisterEvent SDB, "OnTrackEnd", "PlayerTrackEnd"
    Else
		On Error Resume Next
		SDB.Player.StopAfterCurrent = False	
		GapTimer.Enabled = False
		Script.UnregisterEvents SDB
		If isObject(GapProgress) Then Set GapProgress = Nothing
		On Error GoTo 0
    End If
End Sub

'---------------------
Sub InitTimer()
	Set GapTimer = SDB.CreateTimer(1000)
	GapTimer.Enabled = False
	Script.RegisterEvent GapTimer, "OnTimer", "GapOnTimer"
End Sub

'---------------------
Sub PlayerOnPlay()
   If GapTimer.Enabled Then
      GapTimer.Enabled = False
      If isObject(GapProgress) Then Set GapProgress = Nothing
   End If

   If SilenceEnabled Then
      If ExcludeGapless Then
         isGapless = CBool(InStr(Eval("SDB.Player.CurrentSong.Custom"&CustomFieldToUse), CustomFieldText))
         SDB.Player.StopAfterCurrent = NOT isGapless
      Else
         SDB.Player.StopAfterCurrent = True
      End If
      CurrentTrack = SDB.Player.CurrentSongIndex   'Save current playing track position
   End If
End Sub

'---------------------
Sub PlayerTrackEnd()
   If SilenceEnabled  And (SDB.Player.CurrentSongIndex+1 < SDB.Player.PlayListCount Or SDB.Player.IsRepeat Or SDB.Player.IsShuffle) Then
      If ExcludeGapless And isGapless Then
       	 GapTimer.Enabled = False
         Set GapProgress = Nothing
      Else
         Set GapProgress = SDB.Progress
         GapProgress.MaxValue = SilenceTime
		GapProgress.Text="Gap " & SilenceTime & " seconds."
		SDB.ProcessMessages
		GapTimer.Enabled = True
      End If
   Else
      GapTimer.Enabled = False
      Set GapProgress = Nothing
   End If
End Sub

'---------------------
Sub GapOnTimer(Timer)
   If Timer.Enabled Then
	GapProgress.Increase
	GapProgress.Text="Gap " & SilenceTime - GapProgress.Value & " seconds."
	SDB.ProcessMessages
   End If
   If GapProgress.Value >= GapProgress.MaxValue Then
	Timer.Enabled = False
	Set GapProgress = Nothing
	If CurrentTrack <> SDB.Player.CurrentSongIndex Then SDB.Player.Play      
   End If
End Sub

'---------------------
Sub InitSheet(Sheet)
   Dim oPanel1, oCheck1, oSpin1, oPanel2, oCheck2, oField2, oString2

   With SDB.UI.NewLabel(Sheet)
      .Common.Left = 460
      .Common.Top = 5
      .Caption = "v" & cVersion
   End With

   With SDB.UI.NewLabel(Sheet)
      .Alignment = 2    'Center
      .Common.SetRect 85,30,280,40
      .Caption = "Adds silence between playing songs." & vbcrlf & _
                 "Can also be enabled/disabled through Play menu."
   End With

   Set oPanel1 = SDB.UI.NewGroupBox(Sheet)
   oPanel1.Common.SetRect 85,80,280,100
   oPanel1.Caption = "Delay between songs"

   Set oCheck1 = SDB.UI.NewCheckBox(oPanel1)
   With oCheck1
      .Caption = "Enable"
      .Common.Left = 25
      .Common.Top = 25
      .Common.ControlName = "ChEnable"
      .Checked = SilenceEnabled
   End With


   Set oSpin1 = SDB.UI.NewSpinEdit(oPanel1)
   With oSpin1
      .Common.Left = 25
      .Common.Top = 55
      .Common.Width = 45
      .MinValue = 1
      .MaxValue = 15
      .Common.ControlName = "EdLength"
      .Value = SilenceTime
   End With

   With SDB.UI.NewLabel(oPanel1)
      .caption = "second(s)"
      .Common.Left = 80
      .Common.Top = 58
   End With
   
   ' ---------------------------------------
   Set oPanel2 = SDB.UI.NewGroupBox(Sheet)
   oPanel2.Common.SetRect 85,200,280,123
   oPanel2.Caption = "Options"

   Set oCheck2 = SDB.UI.NewCheckBox(oPanel2)
   With oCheck2
      .Caption = "Exclude gapless tracks"
      .Common.Left = 25
      .Common.Top = 25
      .Common.Width = 220
      .Common.ControlName = "ChEnable2"
      .Checked = ExcludeGapless
   End With
   
   With SDB.UI.NewLabel(oPanel2)
      .caption = "Noted anywhere in:"
      .Common.Left = 25
      .Common.Top = 58
   End With
   
   Set oField2 = SDB.UI.NewDropDown(oPanel2)
   With oField2
      .Common.ControlName = "oFieldToUse"
      .Style = 2        'csDropDownList
      .Common.SetRect 150,55,100,21
      .AddItem "Custom1"
      .AddItem "Custom2"
      .AddItem "Custom3"
      .AddItem "Custom4"
      .AddItem "Custom5"
      .ItemIndex = CustomFieldToUse - 1
    End With  

   With SDB.UI.NewLabel(oPanel2)
      .caption = "As (text):"
      .Common.Left = 25
      .Common.Top = 83
   End With

   Set oString2 = SDB.UI.NewEdit(oPanel2)
   With oString2
      .Common.ControlName = "oFieldText"
      .Common.SetRect 120,80,130,21
      .Text = CustomFieldText
   End With
End Sub

'---------------------
Sub SaveSheet(Sheet)
	Dim SheetCommon : Set SheetCommon = Sheet.Common

	If SheetCommon.ChildControl("ChEnable").Checked <> SilenceEnabled then
		ToggleSilence 0
	End If
    
	' Extact values:
	SilenceTime = SheetCommon.ChildControl("EdLength").Value
	ExcludeGapless = SheetCommon.ChildControl("ChEnable2").Checked
	CustomFieldToUse = SheetCommon.ChildControl("oFieldToUse").ItemIndex + 1
	CustomFieldText = SheetCommon.ChildControl("oFieldText").Text
	If Len(CustomFieldText)=0 Then CustomFieldText = DEFAULTCustomFieldText
   
    ' Write values:
	Dim Reg : Set Reg = SDB.Registry
	If Reg.OpenKey(AppTitle, True) Then
		Reg.BoolValue("Enabled") = SilenceEnabled
		Reg.StringValue("SilenceTime") = SilenceTime
		Reg.BoolValue("ExcludeGapless") = ExcludeGapless
		Reg.StringValue("CustomFieldToUse") = CustomFieldToUse
		Reg.StringValue("CustomFieldText") = CustomFieldText
		Reg.CloseKey
	End If
End Sub
