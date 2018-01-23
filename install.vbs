Option Explicit

Dim SilenceTime : SilenceTime = 3
Dim SilenceEnabled : SilenceEnabled = False
Dim isGapless : isGapless = False
Dim ExcludeGapless : ExcludeGapless = False
Dim CustomFieldToUse : CustomFieldToUse = 3
Dim CustomFieldText : CustomFieldText = "[Gapless]"
Dim AppTitle : AppTitle = "SilenceBetweenSongs"
Dim cVersion : cVersion = "5.0.0.0"

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
End If
