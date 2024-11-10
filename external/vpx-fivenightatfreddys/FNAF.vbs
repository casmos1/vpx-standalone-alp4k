' ****************************************************************
'                       VISUAL PINBALL X
'                		FNAF - by drjameshouse and remdwaas
'                       Version 1.0.0
'						started 25-05-2021
' ****************************************************************

'DOF Config by OUTHERE
'101 Left Flipper
'102 Right Flipper
'103 Left Slingshot
'104 
'105 Right Slingshot
'106 
'107 Bumper Left
'108 Bumper Center
'109 Bumper Right
'110 
'111 
'112 Spinner 1 Left
'113 Spinner 2 Right
'114 Kicker 1 Left  Solenoid
'115 kicker 2 Right Solenoid
'116 Beacon kicker
'117 Beacon kicker
'118 
'119 
'120 
'121 AutoPlunger
'122 Knocker
'123 Ball Release

Option Explicit
'****** PuP Variables ******

Dim usePUP: Dim cPuPPack: Dim PuPlayer: Dim PUPStatus: PUPStatus=false ' dont edit this line!!!

'*************************** PuP Settings for this table ********************************

usePUP   = False               ' enable Pinup Player functions for this table
cPuPPack = "FNAF"    ' name of the PuP-Pack / PuPVideos folder for this table

'//////////////////// PINUP PLAYER: STARTUP & CONTROL SECTION //////////////////////////

' This is used for the startup and control of Pinup Player

Sub PuPStart(cPuPPack)
    If PUPStatus=true then Exit Sub
    If usePUP=true then
        Set PuPlayer = CreateObject("PinUpPlayer.PinDisplay")
        If PuPlayer is Nothing Then
            usePUP=false
            PUPStatus=false
        Else
            PuPlayer.B2SInit "",cPuPPack 'start the Pup-Pack
            PUPStatus=true
        End If
    End If
End Sub

Sub pupevent(EventNum)
    if (usePUP=false or PUPStatus=false) then Exit Sub
    PuPlayer.B2SData "E"&EventNum,1  'send event to Pup-Pack
End Sub

' ******* How to use PUPEvent to trigger / control a PuP-Pack *******

' Usage: pupevent(EventNum)

' EventNum = PuP Exxx trigger from the PuP-Pack

' Example: pupevent 102

' This will trigger E102 from the table's PuP-Pack

' DO NOT use any Exxx triggers already used for DOF (if used) to avoid any possible confusion

'************ PuP-Pack Startup **************

PuPStart(cPuPPack) 'Check for PuP - If found, then start Pinup Player / PuP-Pack
Randomize

Const BallSize = 50    ' 50 is the normal size used in the core.vbs, VP kicker routines uses this value divided by 2
Const BallMass = 1
Const SongVolume = 0.1 ' 1 is full volume. Value is from 0 to 1

' Load the core.vbs for supporting Subs and functions
LoadCoreFiles

Sub LoadCoreFiles
    On Error Resume Next
    ExecuteGlobal GetTextFile("core.vbs")
    If Err Then MsgBox "Can't open core.vbs"
    ExecuteGlobal GetTextFile("controller.vbs")
    If Err Then MsgBox "Can't open controller.vbs"
    On Error Goto 0
End Sub

' Define any Constants
Const cGameName = "FNAF"
Const TableName = "FNAF"
Const myVersion = "1.0.0"
Const MaxPlayers = 4     ' from 1 to 4
Const BallSaverTime = 20 ' in seconds
Const MaxMultiplier = 14  ' Playfield multiplier
Const BallsPerGame = 5   ' usually 3 or 5
Const MaxMultiballs = 4  ' max number of balls during multiballs

Const Special1 = 1000000  ' High score to obtain an extra ball/game
Const Special2 = 3000000
Const Special3 = 5000000

Sub startB2S(aB2S)
	If B2SOn Then
	Controller.B2SSetData 1,0
	Controller.B2SSetData 2,0
	Controller.B2SSetData 3,0
	Controller.B2SSetData aB2S,1
	End If
End Sub

' Game Mode constants
Const DAYTIME = 1
Const NIGHTTIME = 2

Const CupcakeWobbleInterval = 10
WobbleMagnetInit


' Use FlexDMD if in FS mode
Dim UseFlexDMD
If Table1.ShowDT = True then
    UseFlexDMD = True
Else
    UseFlexDMD = True
End If

' Define Global Variables
Dim PlayersPlayingGame
Dim CurrentPlayer
Dim Credits
Dim BonusPoints(4)
Dim BonusMultiplier(4)
Dim PlayfieldMultiplier(4)
Dim bBonusHeld
Dim BallsRemaining(4)
Dim ExtraBallsAwards(4)
Dim Special1Awarded(4)
Dim Special2Awarded(4)
Dim Special3Awarded(4)
Dim Score(4)
Dim HighScore(4)
Dim HighScoreName(4)
Dim Tilt
Dim TiltSensitivity
Dim Tilted
Dim TotalGamesPlayed
Dim bAttractMode
Dim mBalls2Eject
Dim bAutoPlunger

' Define Game Control Variables
Dim BallsOnPlayfield
Dim BallsInLock
Dim BallsInHole

' Define Game Flags
Dim bFreePlay
Dim bGameInPlay
Dim bOnTheFirstBall
Dim bBallInPlungerLane
Dim bBallSaverActive
Dim bBallSaverReady
Dim bMultiBallMode
'Dim Multiball
Dim bMusicOn
Dim bJustStarted
Dim bJackpot
Dim plungerIM
Dim LastSwitchHit
dim Tfnaf
dim TfnafN
dim Tnights
Dim GameMode
Dim GatesCount(4)
Dim mModeMagnet
dim Playkitchen
dim Playstage
dim getitemleft
dim getitemright
dim countr
dim countr2
dim countr3
dim countr4
dim countr5
dim countr6
dim countr7
dim countr8
dim countr9
dim countr10
dim countr11

' core.vbs variables

' *********************************************************************
'                Visual Pinball Defined Script Events
' *********************************************************************

Sub Table1_Init()
    LoadEM
	Dim i
	'Randomize

'reset HighScore
'Reseths

'Impulse Plunger as autoplunger
    Const IMPowerSetting = 36 ' Plunger Power
    Const IMTime = 1.1        ' Time in seconds for Full Plunge
    Set plungerIM = New cvpmImpulseP
    With plungerIM
        .InitImpulseP swplunger, IMPowerSetting, IMTime
        .Random 1.5
        .InitExitSnd SoundFXDOF("fx_kicker", 141, DOFPulse, DOFContactors), SoundFXDOF("fx_solenoid", 141, DOFPulse, DOFContactors)
        .CreateEvents "plungerIM"
    End With

    ' Misc. VP table objects Initialisation, droptargets, animations...
    VPObjects_Init

    ' load saved values, highscore, names, jackpot
    Loadhs

    'Init main variables
    For i = 1 To MaxPlayers
        Score(i) = 0
        BonusPoints(i) = 0
        BonusMultiplier(i) = 1
        PlayfieldMultiplier(i) = 1
        BallsRemaining(i) = BallsPerGame
        ExtraBallsAwards(i) = 0
    Next

    ' Initalise the DMD display
    DMD_Init

    ' freeplay or coins
    bFreePlay = False 'we want coins

    'if bFreePlay = false Then DOF 125, DOFOn

    ' set all bumper cupcake timer intervals
    cupcake001_Timer.Interval = CupcakeWobbleInterval
    cupcake002_Timer.Interval = CupcakeWobbleInterval
    cupcake003_Timer.Interval = CupcakeWobbleInterval

    Set mModeMagnet = New cvpmTableMagnet
	With mModeMagnet
	   .InitMagnet ModeMagnet, 4	' was 60 power
	   .MagnetOn = False
	   .CreateEvents "mModeMagnet"
	End With

    ' Init main variables and any other flags
    bAttractMode = False
    bOnTheFirstBall = False
    bBallInPlungerLane = False
    bBallSaverActive = False
    bBallSaverReady = False
    bGameInPlay = False
    bMusicOn = True
    BallsOnPlayfield = 0
	bMultiBallMode = False
	'Multiball=false
	bAutoPlunger = False
    BallsInLock = 0
    BallsInHole = 0
	LastSwitchHit = ""
    Tilt = 0
    TiltSensitivity = 6
    Tilted = False
    bJustStarted = True
    ' set any lights for the attract mode
    GiOff
    StartAttractMode
	'EndOfGame()
End Sub

'****************************************
' Real Time updatess using the GameTimer
'****************************************
'used for all the real time updates
Dim BalloonFrame, BalloonFrameNext, BalloonFrameRate  
BalloonFrame = 1
BalloonFrameRate = 0.05
BalloonFrameNext = BalloonFrameRate


Sub GameTimer_Timer
    RollingUpdate
    ' add any other real time update subs, like gates or diverters
    FlipperLSh.Rotz = LeftFlipper.CurrentAngle
    FlipperRSh.Rotz = RightFlipper.CurrentAngle
	'AnimateBalloon
	Balloon.ShowFrame(BalloonFrame)
	BalloonFrame = BalloonFrame + BalloonFrameNext
If BalloonFrame > 9 OR BalloonFrame < 1 Then
				'Change the direction of the frame step
				BalloonFrameNext = BalloonFrameNext * -1
			end if
End Sub

'******
' Keys
'******

Sub Table1_KeyDown(ByVal Keycode)
    If Keycode = AddCreditKey Then
        Credits = Credits + 1
        if bFreePlay = False Then
            DOF 125, DOFOn
            If(Tilted = False) Then
                DMDFlush
                DMD "_", CL(1, "CREDITS: " & Credits), "", eNone, eNone, eNone, 500, True, "fx_coin"
            End If
        End If
    End If

    If keycode = PlungerKey Then
        Plunger.Pullback
        PlaySound "plungerpull3"
 '       PlaySoundAt "plungerpull", plunger
 '       PlaySoundAt "fx_reload", plunger
    End If

    If hsbModeActive Then
        EnterHighScoreKey(keycode)
        Exit Sub
    End If

    ' Normal flipper action

    If bGameInPlay AND NOT Tilted Then

        If keycode = LeftTiltKey Then Nudge 90, 8:PlaySound "fx_nudge", 0, 1, -0.1, 0.25:CheckTilt
        If keycode = RightTiltKey Then Nudge 270, 8:PlaySound "fx_nudge", 0, 1, 0.1, 0.25:CheckTilt
        If keycode = CenterTiltKey Then Nudge 0, 9:PlaySound "fx_nudge", 0, 1, 1, 0.25:CheckTilt

        If keycode = LeftFlipperKey Then SolLFlipper 1
        If keycode = RightFlipperKey Then SolRFlipper 1

        If keycode = StartGameKey Then
            If((PlayersPlayingGame <MaxPlayers) AND(bOnTheFirstBall = True) ) Then

                If(bFreePlay = True) Then
                    PlayersPlayingGame = PlayersPlayingGame + 1
                    TotalGamesPlayed = TotalGamesPlayed + 1
                    DMD "_", CL(1, PlayersPlayingGame & " PLAYERS"), "", eNone, eBlink, eNone, 500, True, "so_fanfare1"
                Else
                    If(Credits> 0) then
                        PlayersPlayingGame = PlayersPlayingGame + 1
                        TotalGamesPlayed = TotalGamesPlayed + 1
                        Credits = Credits - 1
                        DMD "_", CL(1, PlayersPlayingGame & " PLAYERS"), "", eNone, eBlink, eNone, 500, True, "so_fanfare1"
                        If Credits <1 And bFreePlay = False Then DOF 125, DOFOff
                        Else
                            ' Not Enough Credits to start a game.
                            DMD CL(0, "CREDITS " & Credits), CL(1, "INSERT COIN"), "", eNone, eBlink, eNone, 500, True, "so_nocredits"
                    End If
                End If
            End If
        End If
        Else ' If (GameInPlay)
            If keycode = StartGameKey Then
                If(bFreePlay = True) Then
                    If(BallsOnPlayfield = 0) Then
                        ResetForNewGame()
						UpdateMusicNow
                    End If
                Else
                    If(Credits> 0) Then
                        If(BallsOnPlayfield = 0) Then
                            Credits = Credits - 1
                            If Credits <1 And bFreePlay = False Then DOF 125, DOFOff
                            ResetForNewGame()
							UpdateMusicNow
                        End If
                    Else
                        ' Not Enough Credits to start a game.
                        DMD CL(0, "CREDITS " & Credits), CL(1, "INSERT COIN"), "", eNone, eBlink, eNone, 500, True, "so_nocredits"
                    End If
                End If
            End If:pupevent 800
    End If ' If (GameInPlay)

'table keys
'If keycode = RightMagnaSave or keycode = LeftMagnasave Then ShowPost 
End Sub

Sub Table1_KeyUp(ByVal keycode)
    If keycode = PlungerKey Then
        Plunger.Fire
        PlaySoundAt "fx_plunger", plunger
        If bBallInPlungerLane Then PlaySoundAt "fx_fire", plunger
    End If

    If hsbModeActive Then
        Exit Sub
    End If

    ' Table specific

    If bGameInPLay AND NOT Tilted Then
        If keycode = LeftFlipperKey Then
            SolLFlipper 0
        End If
        If keycode = RightFlipperKey Then
            SolRFlipper 0
        End If
    End If
End Sub

'*************
' Pause Table
'*************

Sub table1_Paused
End Sub

Sub table1_unPaused
End Sub

Sub Table1_Exit
    Savehs
    If B2SOn = true Then Controller.Stop
End Sub

'********************
'     Flippers
'********************

Sub SolLFlipper(Enabled)
    If Enabled Then
        PlaySoundAt SoundFXDOF("fx_flipperup", 101, DOFOn, DOFFlippers), LeftFlipper
        LeftFlipper.RotateToEnd
'		Flipper1.RotateToEnd 'Adds To End Movement for Flipper1
		if GameMode = DAYTIME then
            RotateLaneLightsLeft
            RotateLaneLightsLeft3
		elseif GameMode = NIGHTTIME then
            RotateLaneLightsLeft2
            RotateLaneLightsLeft4
		end If
    Else
        PlaySoundAt SoundFXDOF("fx_flipperdown", 101, DOFOff, DOFFlippers), LeftFlipper
        LeftFlipper.RotateToStart
'		Flipper1.RotateToStart 'Adds To End Movement for Flipper1
    End If
End Sub

Sub SolRFlipper(Enabled)
    If Enabled Then
        PlaySoundAt SoundFXDOF("fx_flipperup", 102, DOFOn, DOFFlippers), RightFlipper
        RightFlipper.RotateToEnd
		if GameMode = DAYTIME then
            RotateLaneLightsRight
            RotateLaneLightsRight3
		elseif GameMode = NIGHTTIME then
            RotateLaneLightsRight2
            RotateLaneLightsRight4
		end if
    Else
        PlaySoundAt SoundFXDOF("fx_flipperdown", 102, DOFOff, DOFFlippers), RightFlipper
        RightFlipper.RotateToStart
    End If
End Sub

' flippers hit Sound

Sub LeftFlipper_Collide(parm)
    PlaySound "fx_rubber_flipper", 0, parm / 10, pan(ActiveBall), 0, Pitch(ActiveBall), 0, 0, AudioFade(ActiveBall)
End Sub

Sub RightFlipper_Collide(parm)
    PlaySound "fx_rubber_flipper", 0, parm / 10, pan(ActiveBall), 0, Pitch(ActiveBall), 0, 0, AudioFade(ActiveBall)
End Sub


Sub RotateLaneLightsLeft
    Dim TempState
    TempState = LeftOutlane.State
    LeftOutlane.State = LeftInlane.State
    LeftInlane.State = RightInlane.State
    RightInlane.State = RightOutlane.State
    RightOutlane.State = TempState
End Sub

Sub RotateLaneLightsRight
    Dim TempState
    TempState = RightOutlane.State
    RightOutlane.State = RightInlane.State
    RightInlane.State = LeftInlane.State
    LeftInlane.State = LeftOutlane.State
    LeftOutlane.State = TempState
End Sub

Sub RotateLaneLightsLeft2
    Dim TempState
    TempState = li011.State
    li011.State = li012.State
    li012.State = li013.State
    li013.State = li014.State
    li014.State = TempState
End Sub

Sub RotateLaneLightsRight2
    Dim TempState
    TempState = li014.State
    li014.State = li013.State
    li013.State = li012.State
    li012.State = li011.State
    li011.State = TempState
End Sub

Sub RotateLaneLightsLeft3
    Dim TempState
    TempState = li041.State
    li041.State = li042.State
    li042.State = li043.State
    li043.state = TempState
End Sub

Sub RotateLaneLightsRight3
    Dim TempState
    TempState = li043.State
    li043.State = li042.State
    li042.State = li041.State
    li041.state = TempState
End Sub

Sub RotateLaneLightsLeft4
    Dim TempState
    TempState = li015.State
    li015.State = li016.State
    li016.State = li017.State
    li017.state = TempState
End Sub

Sub RotateLaneLightsRight4
    Dim TempState
    TempState = li017.State
    li017.State = li016.State
    li016.State = li015.State
    li015.state = TempState
End Sub


'*********
' TILT
'*********

'NOTE: The TiltDecreaseTimer Subtracts .01 from the "Tilt" variable every round

Sub CheckTilt                                    'Called when table is nudged
    Tilt = Tilt + TiltSensitivity                'Add to tilt count
    TiltDecreaseTimer.Enabled = True
    If(Tilt> TiltSensitivity) AND(Tilt <15) Then 'show a warning
        DMD "_", CL(1, "CAREFUL!"), "", eNone, eBlinkFast, eNone, 500, True, ""
    End if
    If Tilt> 15 Then 'If more that 15 then TILT the table
        TiltTable
    End If
End Sub

Sub TiltTable()
    Tilted = True
    'display Tilt
    DMDFlush
    DMD "", "", "TILT", eNone, eNone, eBlink, 200, False, ""
    DisableTable True
    TiltRecoveryTimer.Enabled = True 'start the Tilt delay to check for all the balls to be drained
End Sub

Sub TiltDecreaseTimer_Timer
    ' DecreaseTilt
    If Tilt> 0 Then
        Tilt = Tilt - 0.1
    Else
        TiltDecreaseTimer.Enabled = False
    End If
End Sub

Sub DisableTable(Enabled)
    If Enabled Then
        'turn off GI and turn off all the lights
        GiOff
        LightSeqTilt.Play SeqAllOff
        'Disable slings, bumpers etc
        LeftFlipper.RotateToStart
        RightFlipper.RotateToStart
'       Bumper1.Force = 0
'       Bumper2.Force = 0
'		Bumper3.Force = 0
        LeftSlingshot.Disabled = 1
        RightSlingshot.Disabled = 1
    Else
        'turn back on GI and the lights
        GiOn
        LightSeqTilt.StopPlay
'        Bumper1.Force = 8
'        Bumper2.Force = 8
'		Bumper3.Force = 8
        LeftSlingshot.Disabled = 0
        RightSlingshot.Disabled = 0
        'clean up the buffer display
        DMDFlush
    End If
End Sub

' GI light sequence effects

Sub GiEffect(n)
    Select Case n
        Case 0 'all blink
            LightSeqGi.UpdateInterval = 8
            LightSeqGi.Play SeqBlinking, , 5, 50
        Case 1 'random
            LightSeqGi.UpdateInterval = 10
            LightSeqGi.Play SeqRandom, 5, , 1000
        Case 2 'upon
            LightSeqGi.UpdateInterval = 4
            LightSeqGi.Play SeqUpOn, 5, 1
    End Select
End Sub

Sub LightEffect(n)
    Select Case n
        Case 0 'all blink
            LightSeqInserts.UpdateInterval = 8
            LightSeqInserts.Play SeqBlinking, , 5, 50
        Case 1 'random
            LightSeqInserts.UpdateInterval = 10
            LightSeqInserts.Play SeqRandom, 5, , 1000
        Case 2 'upon
            LightSeqInserts.UpdateInterval = 4
            LightSeqInserts.Play SeqUpOn, 10, 1
        Case 3 ' left-right-left
            LightSeqInserts.UpdateInterval = 5
            LightSeqInserts.Play SeqLeftOn, 10, 1
            LightSeqInserts.UpdateInterval = 5
            LightSeqInserts.Play SeqRightOn, 10, 1
    End Select
End Sub

Sub TiltRecoveryTimer_Timer()
    ' if all the balls have been drained then..
    If(BallsOnPlayfield = 0) Then
        ' do the normal end of ball thing (this doesn't give a bonus if the table is tilted)
        EndOfBall()
        TiltRecoveryTimer.Enabled = False
    End If
' else retry (checks again in another second or so)
End Sub

'********************
' Music as wav sounds
'********************

Dim Song, UpdateMusic
Song = ""

Sub PlaySong(name)
    If bMusicOn Then
        If Song <> name Then
            StopSound Song
            Song = name
            PlaySound Song, -1, SongVolume
        End If
    End If
End Sub

Sub StopSong
    If bMusicOn Then
        StopSound Song
        Song = ""
    End If
End Sub

Sub ChangeSong
    If(BallsOnPlayfield = 0)Then
        PlaySong "M_end"
        Exit Sub
    End If

    If bAttractMode Then
        PlaySong "M_end"
        Exit Sub
    End If
    If bMultiBallMode Then
        PlaySong "MULTI"
    Else
        UpdateMusicNow
    end if
End Sub

'if you add more balls to the game use changesong then if bMultiBallMode = true, your multiball song will be played.

Sub UpdateMusicNow
    Select Case UpdateMusic
        Case 0:PlaySong "1"
        Case 1:PlaySong "2"
        Case 2:PlaySong "3"
        Case 3:PlaySong "4"
        Case 4:PlaySong "5"
        Case 5:PlaySong "M_end"
        'Case 6:PlaySong "chooseplayer2"
    End Select
end sub:pupevent 806

Sub Pin001_hit()
Playsound "Rubber_4"
end sub

Sub Pin002_hit()
Playsound "Rubber_4"
end sub

Sub Pin3_hit()
Playsound "Rubber_4"
end sub

Sub Pin4_hit()
Playsound "Rubber_4"
end sub

'********************
' Play random quotes
'********************

Sub PlayQuote
    Dim tmp
    tmp = INT(RND * 123) + 1
    PlaySound "HIT_" &tmp
End Sub

'**********************
'     GI effects
' independent routine
' it turns on the gi
' when there is a ball
' in play
'**********************

Dim OldGiState
OldGiState = -1   'start witht the Gi off

Sub ChangeGi(col) 'changes the gi color
    Dim bulb
    For each bulb in aGILights
        SetLightColor bulb, col, -1
    Next
End Sub

Sub GIUpdateTimer_Timer
    Dim tmp, obj
    tmp = Getballs
    If UBound(tmp) <> OldGiState Then
        OldGiState = Ubound(tmp)
        If UBound(tmp) = 1 Then 'we have 2 captive balls on the table (-1 means no balls, 0 is the first ball, 1 is the second..)
            GiOff               ' turn off the gi if no active balls on the table, we could also have used the variable ballsonplayfield.
        Else
            Gion
        End If
    End If
End Sub

Sub GiOn
    DOF 127, DOFOn
    Dim bulb
    For each bulb in aGiLights
        bulb.State = 1
    Next
    For each bulb in aBumperLights
        bulb.State = 1
    Next
' table1.ColorGradeImage = "ColorGradeLUT256x16_HalfSat"
End Sub

Sub GiOff
    DOF 127, DOFOff
    Dim bulb
    For each bulb in aGiLights
        bulb.State = 0
    Next
    For each bulb in aBumperLights
        bulb.State = 0
    Next
' table1.ColorGradeImage = "ColorGradeLUT256x16_HalfSat-dark"
End Sub

' GI, light & flashers sequence effects

Sub GiEffect(n)
    Dim ii
    Select Case n
        Case 0 'all off
            LightSeqGi.Play SeqAlloff
        Case 1 'all blink
            LightSeqGi.UpdateInterval = 10
            LightSeqGi.Play SeqBlinking, , 15, 10
        Case 2 'random
            LightSeqGi.UpdateInterval = 10
            LightSeqGi.Play SeqRandom, 50, , 1000
        Case 3 'all blink fast
            LightSeqGi.UpdateInterval = 10
            LightSeqGi.Play SeqBlinking, , 10, 10
        Case 4 'all blink once
            LightSeqGi.UpdateInterval = 10
            LightSeqGi.Play SeqBlinking, , 4, 1
    End Select
End Sub

Sub LightEffect(n)
    Select Case n
        Case 0 ' all off
            LightSeqInserts.Play SeqAlloff
        Case 1 'all blink
            LightSeqInserts.UpdateInterval = 10
            LightSeqInserts.Play SeqBlinking, , 15, 10
        Case 2 'random
            LightSeqInserts.UpdateInterval = 10
            LightSeqInserts.Play SeqRandom, 50, , 1000
        Case 3 'all blink fast
            LightSeqInserts.UpdateInterval = 10
            LightSeqInserts.Play SeqBlinking, , 10, 10
        Case 4 'up 1 time
            LightSeqInserts.UpdateInterval = 4
            LightSeqInserts.Play SeqUpOn, 8, 1
        Case 5 'up 2 times
            LightSeqInserts.UpdateInterval = 4
            LightSeqInserts.Play SeqUpOn, 8, 2
        Case 6 'down 1 time
            LightSeqInserts.UpdateInterval = 4
            LightSeqInserts.Play SeqDownOn, 8, 1
        Case 7 'down 2 times
            LightSeqInserts.UpdateInterval = 4
            LightSeqInserts.Play SeqDownOn, 8, 2
    End Select
End Sub

' *********************************************************************
'                      Supporting Ball & Sound Functions
' *********************************************************************

Function Vol(ball) ' Calculates the Volume of the sound based on the ball speed
    Vol = Csng(BallVel(ball) ^2 / 2000)
End Function

Function Pan(ball) ' Calculates the pan for a ball based on the X position on the table. "table1" is the name of the table
    Dim tmp
    tmp = ball.x * 2 / table1.width-1
    If tmp > 0 Then
        Pan = Csng(tmp ^10)
    Else
        Pan = Csng(-((- tmp) ^10))
    End If
End Function

Function Pitch(ball) ' Calculates the pitch of the sound based on the ball speed
    Pitch = BallVel(ball) * 20
End Function

Function BallVel(ball) 'Calculates the ball speed
    BallVel = (SQR((ball.VelX ^2) + (ball.VelY ^2)))
End Function

Function AudioFade(ball) 'only on VPX 10.4 and newer
    Dim tmp
    tmp = ball.y * 2 / Table1.height-1
    If tmp > 0 Then
        AudioFade = Csng(tmp ^10)
    Else
        AudioFade = Csng(-((- tmp) ^10))
    End If
End Function

Sub PlaySoundAt(soundname, tableobj) 'play sound at X and Y position of an object, mostly bumpers, flippers and other fast objects
    PlaySound soundname, 0, 1, Pan(tableobj), 0.06, 0, 0, 0, AudioFade(tableobj)
End Sub

Sub PlaySoundAtBall(soundname) ' play a sound at the ball position, like rubbers, targets, metals, plastics
    PlaySound soundname, 0, Vol(ActiveBall), pan(ActiveBall), 0.2, 0, 0, 0, AudioFade(ActiveBall)
End Sub

'********************************************
'   JP's VP10 Rolling Sounds + Ballshadow
' uses a collection of shadows, aBallShadow
'********************************************

Const tnob = 20 ' total number of balls
Const lob = 0   'number of locked balls
ReDim rolling(tnob)
InitRolling

Sub InitRolling
    Dim i
    For i = 0 to tnob
        rolling(i) = False
    Next
End Sub

Sub RollingUpdate()
    Dim BOT, b, ballpitch, ballvol
    BOT = GetBalls

    ' stop the sound of deleted balls
    For b = UBound(BOT) + 1 to tnob
        rolling(b) = False
        StopSound("fx_ballrolling" & b)
    Next

    ' exit the sub if no balls on the table
    If UBound(BOT) = lob - 1 Then Exit Sub 'there no extra balls on this table

    ' play the rolling sound for each ball and draw the shadow
    For b = lob to UBound(BOT)
        aBallShadow(b).X = BOT(b).X
        aBallShadow(b).Y = BOT(b).Y

        If BallVel(BOT(b) )> 1 Then
            If BOT(b).z <30 Then
                ballpitch = Pitch(BOT(b) )
                ballvol = Vol(BOT(b) )
            Else
                ballpitch = Pitch(BOT(b) ) + 25000 'increase the pitch on a ramp
                ballvol = Vol(BOT(b) ) * 10
            End If
            rolling(b) = True
            PlaySound("fx_ballrolling" & b), -1, ballvol, Pan(BOT(b) ), 0, ballpitch, 1, 0, AudioFade(BOT(b) )
        Else
            If rolling(b) = True Then
                StopSound("fx_ballrolling" & b)
                rolling(b) = False
            End If
        End If
        ' rothbauerw's Dropping Sounds
        If BOT(b).VelZ <-1 and BOT(b).z <55 and BOT(b).z> 27 Then 'height adjust for ball drop sounds
            PlaySound "fx_balldrop", 0, ABS(BOT(b).velz) / 17, Pan(BOT(b) ), 0, Pitch(BOT(b) ), 1, 0, AudioFade(BOT(b) )
        End If
    Next
End Sub

'**********************
' Ball Collision Sound
'**********************

Sub OnBallBallCollision(ball1, ball2, velocity)
    PlaySound "fx_collide", 0, Csng(velocity) ^2 / 2000, Pan(ball1), 0, Pitch(ball1), 0, 0, AudioFade(ball1)
End Sub

'******************************
' Diverse Collection Hit Sounds
'******************************

'Sub aMetals_Hit(idx):PlaySoundAtBall "fx_MetalHit":End Sub
'Sub aRubber_Bands_Hit(idx):PlaySoundAtBall "fx_rubber_band":End Sub
'Sub aRubber_Posts_Hit(idx):PlaySoundAtBall "fx_rubber_post":End Sub
'Sub aRubber_Pins_Hit(idx):PlaySoundAtBall "fx_rubber_pin":End Sub
'Sub aPlastics_Hit(idx):PlaySoundAtBall "fx_PlasticHit":End Sub
'Sub aGates_Hit(idx):PlaySoundAtBall "fx_Gate":End Sub
'Sub aWoods_Hit(idx):PlaySoundAtBall "fx_Woodhit":End Sub

Sub RHelp1_Hit()
    StopSound "fx_metalrolling"
    PlaySoundAtBall "fx_ballrampdrop"
End Sub

Sub RHelp2_Hit()
    StopSound "fx_metalrolling"
    PlaySoundAtBall"fx_ballrampdrop"
End Sub


' *********************************************************************
'                        User Defined Script Events
' *********************************************************************

' Initialise the Table for a new Game
'
Sub ResetForNewGame()
    Dim i

    bGameInPLay = True

    'resets the score display, and turn off attract mode
    StopAttractMode
    GiOn

	'reset variables
	Tfnaf = 0
	TfnafN = 0
	Tnights = 0
	Playkitchen = 0
	Playstage = 0
	stageSlot = 0
	kitchenSlot = 0
	getitemleft = 0
	getitemright = 0
	BallInHole1 = 0
	BallInHole = 0
	countr = 0
	countr2 = 0
	countr4 = 0
	countr3 = 0
	countr5 = 0
	countr6 = 0
	countr7 = 0
	countr8 = 0
	countr9 = 0
	countr10 = 0
	countr11 = 0

    GameMode = DAYTIME

	'reset Images
	Fnafclock.Image="6uur"
	monitoro002.Image="monitor1a"
	monitoro001.Image="monitor1"
	pizzaT001.image = "T_Pizza_40"
	pizzaT002.image = "T_Pizza_40"
	forshotball1a
	Fnight0

	'reset prims
	changetoday
	resetallfornewgamy
	
    TotalGamesPlayed = TotalGamesPlayed + 1
    CurrentPlayer = 1
    PlayersPlayingGame = 1
    bOnTheFirstBall = True
	'Multiball=false	
    For i = 1 To MaxPlayers
        Score(i) = 0
        BonusPoints(i) = 0
		'BonusHeldPoints(i) = 0
        BonusMultiplier(i) = 1
        PlayfieldMultiplier(i) = 1
        BallsRemaining(i) = BallsPerGame
        ExtraBallsAwards(i) = 0
        Special1Awarded(i) = False
        Special2Awarded(i) = False
        Special3Awarded(i) = False
        GatesCount(i) = 0
    Next
    SetMultiplierLights False
    
    ' initialise any other flags
    Tilt = 0

	'reset variables
	'bumperHits = 100

    UpdateMusic = 0
    'UpdateMusic = UpdateMusic + 6
    UpdateMusicNow

    ' initialise Game variables
    Game_Init()
	
    ' you may wish to start some music, play a sound, do whatever at this point
    StopSong
    PlaySound ""


    vpmtimer.addtimer 1500, "FirstBall '"
End Sub

' This is used to delay the start of a game to allow any attract sequence to

' complete.  When it expires it creates a ball for the player to start playing with

Sub FirstBall
    ' reset the table for a new ball
	startB2S(2)
    ResetForNewPlayerBall()
    ' create a new ball in the shooters lane
    CreateNewBall()
End Sub

' (Re-)Initialise the Table for a new ball (either a new ball after the player has
' lost one or we have moved onto the next player (if multiple are playing))

Sub ResetForNewPlayerBall()
    if GameMode = DAYTIME  AND NOT (Playkitchen = 1 or Playstage = 1) then
        Ttimey.enabled = True
     end if
    ' make sure the correct display is upto date
    AddScore 0
	TargetBonus = 0
	bumperHits = 0

    ' set the current players bonus multiplier back down to 1X
    BonusMultiplier(CurrentPlayer) = 1
    'UpdateBonusXLights

    ' reset the playfield multiplier to 1X
    PlayfieldMultiplier(CurrentPlayer) = 1
	
	' reset any drop targets, lights, game Mode etc..
    
   'This is a new ball, so activate the ballsaver
    bBallSaverReady = True

    'Reset any table specific
	BumperBonus = 0
	HoleBonus = 0
	ALLRampBonus = 0
	RampBonus1 = 0
	RampBonus2 = 0
	RampBonus3 = 0
	MulitballBonus = 0

    ResetNewBallLights()
	'Multiball=false
    GatesCount(CurrentPlayer) = 0	
End Sub

' Create a new ball on the Playfield

Sub CreateNewBall()
    
	LightSeqAttract.StopPlay

	' create a ball in the plunger lane kicker.
    BallRelease.CreateSizedBallWithMass BallSize / 2, BallMass

    ' There is a (or another) ball on the playfield
    BallsOnPlayfield = BallsOnPlayfield + 1

    ' kick it out..
    PlaySoundAt SoundFXDOF("fx_Ballrel", 123, DOFPulse, DOFContactors), BallRelease
    BallRelease.Kick 90, 4

	'only this tableDrain / Plunger Functions
	'ChangeBallImage

    If BallsOnPlayfield> 1 Then
        bMultiBallMode = True
        bAutoPlunger = True
        'ChangeSong
    End If

End Sub


' Add extra balls to the table with autoplunger
' Use it as AddMultiball 4 to add 4 extra balls to the table

Sub AddMultiball(nballs)
    mBalls2Eject = mBalls2Eject + nballs
    CreateMultiballTimer.Enabled = True
    'and eject the first ball
    CreateMultiballTimer_Timer
End Sub

' Eject the ball after the delay, AddMultiballDelay
Sub CreateMultiballTimer_Timer()
    ' wait if there is a ball in the plunger lane
    If bBallInPlungerLane Then
        Exit Sub
    Else
        If BallsOnPlayfield < MaxMultiballs Then
            CreateNewBall()
            mBalls2Eject = mBalls2Eject -1
            If mBalls2Eject = 0 Then 'if there are no more balls to eject then stop the timer
                CreateMultiballTimer.Enabled = False
            End If
        Else 'the max number of multiballs is reached, so stop the timer
            mBalls2Eject = 0
            CreateMultiballTimer.Enabled = False
        End If
    End If
End Sub


' The Player has lost his ball (there are no more balls on the playfield).
' Handle any bonus points awarded

Sub EndOfBall()
	Dim BonusDelayTime
	' the first ball has been lost. From this point on no new players can join in
    bOnTheFirstBall = False

    ' only process any of this if the table is not tilted.  (the tilt recovery
    ' mechanism will handle any extra balls or end of game)

	'LightSeqAttract.Play SeqBlinking, , 5, 150

    Ttimey.enabled = false
	Table1.ColorGradeImage = "-30"

    StopSong
    'bonuscheckie
	PlaySound "BALLLOST2"

    Dim AwardPoints, TotalBonus, ii
    AwardPoints = 0
    TotalBonus = 0

    'If NOT Tilted Then
	If(Tilted = False) Then
		
        'Number of Target hits
'       AwardPoints = TargetBonus * 2000
'       TotalBonus = TotalBonus + AwardPoints
'       DMD CL(0, FormatScore(AwardPoints)), CL(1, "TARGET BONUS " & TargetBonus), "", eBlink, eNone, eNone, 300, False, "whip" <- with dmd scores otherwise only total bonus

        AwardPoints = TargetBonus * 15000
        TotalBonus = TotalBonus + AwardPoints
 
        AwardPoints = bumperhits * 10000
        TotalBonus = TotalBonus + AwardPoints
        
		DMD CL(0, FormatScore(TotalBonus) ), CL(1, "TOTAL BONUS" & BonusMultiplier(CurrentPlayer) ), "", eBlinkFast, eNone, eNone, 1000, True, "po_bonus7"
        TotalBonus = TotalBonus * BonusMultiplier(CurrentPlayer)
        
		AddScore TotalBonus

		' add a bit of a delay to allow for the bonus points to be shown & added up
		vpmtimer.addtimer 3300, "EndOfBall2 '"
    Else 'Si hay falta simplemente espera un momento y va directo a la segunta parte después de perder la bola
		BonusDelayTime = 100
		EndOfBall2
    End If
	'vpmtimer.addtimer BonusDelayTime, "EndOfBall2 '"
End Sub

' The Timer which delays the machine to allow any bonus points to be added up
' has expired.  Check to see if there are any extra balls for this player.
' if not, then check to see if this was the last ball (of the CurrentPlayer)
'
Sub EndOfBall2()
    ' if were tilted, reset the internal tilted flag (this will also
    ' set TiltWarnings back to zero) which is useful if we are changing player LOL
	if GameMode = NIGHTTIME then
        Tfnaf = 0
        Fnafclock.Image="6uur"
		monitoro002.Image="monitor1a"
		monitoro001.Image="monitor1"
		resetscare
	end if
    UpdateMusic = UpdateMusic + 1
	UpdateMusicNow	
    Tilted = False
    Tilt = 0
	if UpdateMusic = 0 then
	forshotball1a
	end if
	if UpdateMusic = 1 then
	forshotball2
	end if
	if UpdateMusic = 2 then
	forshotball3a
	end if
	if UpdateMusic = 3 then
	forshotball4
	end if
	if UpdateMusic = 4 then
	forshotball5a
	end if
    DisableTable False 'enable again bumpers and slingshots
    ChangeMode DAYTIME

    ' has the player won an extra-ball ? (might be multiple outstanding)
    If(ExtraBallsAwards(CurrentPlayer) <> 0) Then
        'debug.print "Extra Ball"

        ' yep got to give it to them
        ExtraBallsAwards(CurrentPlayer) = ExtraBallsAwards(CurrentPlayer) - 1

        ' if no more EB's then turn off any shoot again light
        If(ExtraBallsAwards(CurrentPlayer) = 0) Then
            LightShootAgain.State = 0
        End If

        ' You may wish to do a bit of a song AND dance at this point
        DMD CL(0, "EXTRA BALL"), CL(1, "SHOOT AGAIN"), "", eNone, eNone, eBlink, 1000, True, "vo_extraball"

		UpdateMusic = UpdateMusic - 1
		UpdateMusicNow

        ' reset the playfield for the new ball
        ResetForNewPlayerBall()
		
		' set the dropped wall for bonus

		
        ' Create a new ball in the shooters lane
        CreateNewBall()
    Else ' no extra balls

        BallsRemaining(CurrentPlayer) = BallsRemaining(CurrentPlayer) - 1

        ' was that the last ball ?
        If(BallsRemaining(CurrentPlayer) <= 0) Then
            'debug.print "No More Balls, High Score Entry"

            ' Submit the CurrentPlayers score to the High Score system
            CheckHighScore()
        ' you may wish to play some music at this point

        Else

            ' not the last ball (for that player)
            ' if multiple players are playing then move onto the next one
            EndOfBallComplete()
        End If
    End If
End Sub

' This function is called when the end of bonus display
' (or high score entry finished) AND it either end the game or
' move onto the next player (or the next ball of the same player)
'
Sub EndOfBallComplete()
    Dim NextPlayer

    'debug.print "EndOfBall - Complete"

    ' are there multiple players playing this game ?
    If(PlayersPlayingGame> 1) Then
        ' then move to the next player
        NextPlayer = CurrentPlayer + 1
        ' are we going from the last player back to the first
        ' (ie say from player 4 back to player 1)
        If(NextPlayer> PlayersPlayingGame) Then
            NextPlayer = 1
        End If
    Else
        NextPlayer = CurrentPlayer
    End If

    'debug.print "Next Player = " & NextPlayer

    ' is it the end of the game ? (all balls been lost for all players)
    If((BallsRemaining(CurrentPlayer) <= 0) AND(BallsRemaining(NextPlayer) <= 0) ) Then
        ' you may wish to do some sort of Point Match free game award here
        ' generally only done when not in free play mode
		StopSong
		playsound "gameover2" :pupevent 803
		'(DMD CL0, "GAME OVER") "", eNone, 13000, True, ""
		DMD CL(0, "NIGHTS"), CL(1, "SURVIVED " &Tnights), "", eNone, eNone, eNone, 3000, True, ""
		DMD "", "", "dmdgo1", eNone, eNone, eNone, 1500, True, ""
		DMD "", "", "dmdgo2", eNone, eNone, eNone, 1500, True, ""
		DMD "", "", "dmdgo3", eNone, eNone, eNone, 2500, True, ""
        ' set the machine into game over mode
        vpmtimer.addtimer 9500, "EndOfGame() '" :pupevent 805 

    ' you may wish to put a Game Over message on the desktop/backglass

    Else
        ' set the next player
        CurrentPlayer = NextPlayer

        ' make sure the correct display is up to date
        DMDScoreNow

        ' reset the playfield for the new player (or new ball)
        ResetForNewPlayerBall()

        ' AND create a new ball
        CreateNewBall()

        ' play a sound if more than 1 player
        If PlayersPlayingGame> 1 Then
            PlaySound "vo_player" &CurrentPlayer
            DMD "_", CL(1, "PLAYER " &CurrentPlayer), "", eNone, eNone, eNone, 800, True, ""
        End If
    End If
End Sub

' This function is called at the End of the Game, it should reset all
' Drop targets, AND eject any 'held' balls, start any attract sequences etc..

Sub EndOfGame()
    LightSeqAttract.StopPlay
	'debug.print "End Of Game"
    bGameInPLay = False
    ' just ended your game then play the end of game tune
    If NOT bJustStarted Then
        ChangeSong
    End If

    bJustStarted = False
    ' ensure that the flippers are down
    SolLFlipper 0
    SolRFlipper 0

    ' terminate all Mode - eject locked balls
    ' most of the Mode/timers terminate at the end of the ball

    ' set any lights for the attract mode
    GiOff
    StartAttractMode
' you may wish to light any Game Over Light you may have
End Sub

Function Balls
    Dim tmp
    tmp = BallsPerGame - BallsRemaining(CurrentPlayer) + 1
    If tmp> BallsPerGame Then
        Balls = BallsPerGame
    Else
        Balls = tmp
    End If
End Function

' *********************************************************************
'                      Drain / Plunger Functions
' *********************************************************************

' lost a ball ;-( check to see how many balls are on the playfield.
' if only one then decrement the remaining count AND test for End of game
' if more than 1 ball (multi-ball) then kill of the ball but don't create
' a new one
'
Sub Drain_Hit()
    ' Destroy the ball
    Drain.DestroyBall
    BallsOnPlayfield = BallsOnPlayfield - 1 
	'If BallsOnPlayfield<2 Then
	'Multiball=false
	'end if
	StartNightTimer.Enabled = False
	ReleaseBall
    ' pretend to knock the ball into the ball storage mech
    PlaySoundAt "fx_drain", Drain
    'if Tilted then end Ball Mode
    If Tilted Then
        StopEndOfBallMode
    End If
	
    ' if there is a game in progress AND it is not Tilted
    If(bGameInPLay = True) AND(Tilted = False) Then

        ' is the ball saver active,
        If(bBallSaverActive = True) Then
            AddMultiball 1
            bAutoPlunger = True
                    ' yep, create a new ball in the shooters lane
                    ' we use the Addmultiball in case the multiballs are being ejected
            DMD CL(0, "BALL SAVED"), CL(1, "SHOOT AGAIN"), "", eBlink, eBlink, eNone, 800, True, ""
            'vpmtimer.addtimer 1250, "CreateNewBall() '"
            ' you may wish to put something on a display or play a sound at this point
         '   DOF 111,  DOFPulse
  
        Else
			If(BallsOnPlayfield = 1)Then
                ' AND in a multi-ball??
                If(bMultiBallMode = True)then
                    ' not in multiball mode any more
                    bMultiBallMode = False
                    ' you may wish to change any music over at this point and
                    ' turn off any multiball specific lights
				ChangeSong
                End If
            End If :pupevent 801
            ' was that the last ball on the playfield
            If(BallsOnPlayfield = 0) Then

                ' End Mode and timers
				StopSong
				PlaySound ""
                'vpmtimer.addtimer 3000, "ChangeSong '"
                ' Show the end of ball animation
                ' and continue with the end of ball
                ' DMD something?
                StopEndOfBallMode
                vpmtimer.addtimer 200, "EndOfBall '" 'the delay is depending of the animation of the end of ball, since there is no animation then move to the end of ball
            End If
        End If
    End If
End Sub



' The Ball has rolled out of the Plunger Lane and it is pressing down the trigger in the shooters lane
' Check to see if a ball saver mechanism is needed and if so fire it up.

Sub Trigger1_Hit()
	if UpdateMusic = 0 then
	Tchglanes1.enabled = True
	pizzaT001.image = "T_Pizza_40"
	pizzaT002.image = "T_Pizza_40"
	end if
	if UpdateMusic = 1 then
	Tchglanes2.enabled = True
	pizzaT001.image = "T_Pizza_26"
	pizzaT002.image = "T_Pizza_26"
	end if
	if UpdateMusic = 2 then
	Tchglanes3.enabled = True
	pizzaT001.image = "T_Pizza_21"
	pizzaT002.image = "T_Pizza_21"
	end if
	if UpdateMusic = 3 then
	Tchglanes4.enabled = True
	pizzaT001.image = "T_Pizza_12"
	pizzaT002.image = "T_Pizza_12"
	end if
	if UpdateMusic = 4 then
	Tchglanes5.enabled = True
	pizzaT001.image = "T_Pizza_02"
	pizzaT002.image = "T_Pizza_02"
	end if
    If bAutoPlunger Then
        'debug.print "autofire the ball"
        PlungerIM.AutoFire
        DOF 121, DOFPulse
        PlaySoundAt "fx_fire", Trigger1
        bAutoPlunger = False
    End If	
    'StopSong
    DMDScoreNow
    bBallInPlungerLane = True
'    DMD "_", CL(1, "SHOOT THE BALL"), "", eNone, eBlink, eNone, 1000, True, ""
    If(bBallSaverReady = True) AND(BallSaverTime <> 0) And(bBallSaverActive = False) Then
        EnableBallSaver BallSaverTime
    Else
        ' show the message to shoot the ball in case the player has fallen sleep
    '    Trigger1.TimerEnabled = 1
    End If
End Sub

' The ball is released from the plunger

Sub Trigger1_UnHit()
	if UpdateMusic = 0 then
	Tchglanes1.enabled = False
	Tchglanes1a.enabled = True
	end if
	if UpdateMusic = 1 then
	Tchglanes2.enabled = False
	Tchglanes2a.enabled = True
	end if
	if UpdateMusic = 2 then
	Tchglanes3.enabled = False
	Tchglanes3a.enabled = True
	end if
	if UpdateMusic = 3 then
	Tchglanes4.enabled = False
	Tchglanes4a.enabled = True
	end if
	if UpdateMusic = 4 then
	Tchglanes5.enabled = False
	Tchglanes5a.enabled = True
	end if
    bBallInPlungerLane = False
    'LightEffect 4
	'ChangeSong
End Sub


'Sub Trigger1_Timer
'    DMD "_", CL(1, "SHOOT THE BALL"), "", eNone, eNone, eNone, 800, True, ""
'    trigger1.TimerEnabled = 0
'End Sub

Sub EnableBallSaver(seconds)
    'debug.print "Ballsaver started"
    ' set our game flag
    bBallSaverActive = True
    bBallSaverReady = False
    ' start the timer
    BallSaverTimer.Interval = 1000 * seconds
    BallSaverTimer.Enabled = True
    BallSaverSpeedUpTimer.Interval = 1000 * seconds -(1000 * seconds) / 3
    BallSaverSpeedUpTimer.Enabled = True
    ' if you have a ball saver light you might want to turn it on at this point (or make it flash)
    LightShootAgain.BlinkInterval = 160
    LightShootAgain.State = 2
End Sub

' The ball saver timer has expired.  Turn it off AND reset the game flag
'
Sub BallSaverTimer_Timer()
    'debug.print "Ballsaver ended"
    BallSaverTimer.Enabled = False
    ' clear the flag
    bBallSaverActive = False
    ' if you have a ball saver light then turn it off at this point
   LightShootAgain.State = 0
End Sub

Sub BallSaverSpeedUpTimer_Timer()
    'debug.print "Ballsaver Speed Up Light"
    BallSaverSpeedUpTimer.Enabled = False
    ' Speed up the blinking
    LightShootAgain.BlinkInterval = 80
    LightShootAgain.State = 2
End Sub

' *********************************************************************
'                      Supporting Score Functions
' *********************************************************************

' Add points to the score AND update the score board
Sub AddScore(points)
    If Tilted Then Exit Sub

    ' add the points to the current players score variable
    Score(CurrentPlayer) = Score(CurrentPlayer) + points

    ' play a sound for each score
	PlaySound "tone"&points

    ' you may wish to check to see if the player has gotten an extra ball by a high score
    If Score(CurrentPlayer) >= Special1 AND Special1Awarded(CurrentPlayer) = False Then
        AwardExtraBall
        Special1Awarded(CurrentPlayer) = True
    End If
    If Score(CurrentPlayer) >= Special2 AND Special2Awarded(CurrentPlayer) = False Then
        AwardExtraBall
        Special2Awarded(CurrentPlayer) = True
    End If
    If Score(CurrentPlayer) >= Special3 AND Special3Awarded(CurrentPlayer) = False Then
        AwardExtraBall
        Special3Awarded(CurrentPlayer) = True
    End If
End Sub

' Add bonus to the bonuspoints AND update the score board
Sub AddBonus(points) 'not used in this table, since there are many different bonus items.
    If(Tilted = False) Then
        ' add the bonus to the current players bonus variable
        BonusPoints(CurrentPlayer) = BonusPoints(CurrentPlayer) + points
    End if
End Sub

Sub AwardExtraBall()
    DMD "_", CL(1, ("EXTRA BALL WON") ), "", eNone, eBlink, eNone, 1000, True, SoundFXDOF("fx_Knocker", 122, DOFPulse, DOFKnocker)
  '  DOF 121, DOFPulse
    ExtraBallsAwards(CurrentPlayer) = ExtraBallsAwards(CurrentPlayer) + 1
    LightShootAgain.State = 1
    LightEffect 2
End Sub

'*****************************
'    Load / Save / Highscore
'*****************************

Sub Loadhs
    Dim x
    x = LoadValue(TableName, "HighScore1")
    If(x <> "") Then HighScore(0) = CDbl(x) Else HighScore(0) = 100000 End If
    x = LoadValue(TableName, "HighScore1Name")
    If(x <> "") Then HighScoreName(0) = x Else HighScoreName(0) = "AAA" End If
    x = LoadValue(TableName, "HighScore2")
    If(x <> "") then HighScore(1) = CDbl(x) Else HighScore(1) = 100000 End If
    x = LoadValue(TableName, "HighScore2Name")
    If(x <> "") then HighScoreName(1) = x Else HighScoreName(1) = "BBB" End If
    x = LoadValue(TableName, "HighScore3")
    If(x <> "") then HighScore(2) = CDbl(x) Else HighScore(2) = 100000 End If
    x = LoadValue(TableName, "HighScore3Name")
    If(x <> "") then HighScoreName(2) = x Else HighScoreName(2) = "CCC" End If
    x = LoadValue(TableName, "HighScore4")
    If(x <> "") then HighScore(3) = CDbl(x) Else HighScore(3) = 100000 End If
    x = LoadValue(TableName, "HighScore4Name")
    If(x <> "") then HighScoreName(3) = x Else HighScoreName(3) = "DDD" End If
    x = LoadValue(TableName, "Credits")
    If(x <> "") then Credits = CInt(x) Else Credits = 0:If bFreePlay = False Then DOF 125, DOFOff:End If
    x = LoadValue(TableName, "TotalGamesPlayed")
    If(x <> "") then TotalGamesPlayed = CInt(x) Else TotalGamesPlayed = 0 End If
End Sub

Sub Savehs
    SaveValue TableName, "HighScore1", HighScore(0)
    SaveValue TableName, "HighScore1Name", HighScoreName(0)
    SaveValue TableName, "HighScore2", HighScore(1)
    SaveValue TableName, "HighScore2Name", HighScoreName(1)
    SaveValue TableName, "HighScore3", HighScore(2)
    SaveValue TableName, "HighScore3Name", HighScoreName(2)
    SaveValue TableName, "HighScore4", HighScore(3)
    SaveValue TableName, "HighScore4Name", HighScoreName(3)
    SaveValue TableName, "Credits", Credits
    SaveValue TableName, "TotalGamesPlayed", TotalGamesPlayed
End Sub

Sub Reseths
    HighScoreName(0) = "AAA"
    HighScoreName(1) = "BBB"
    HighScoreName(2) = "CCC"
    HighScoreName(3) = "DDD"
    HighScore(0) = 100000
    HighScore(1) = 110000
    HighScore(2) = 120000
    HighScore(3) = 130000
    Savehs
End Sub

' ***********************************************************
'  High Score Initals Entry Functions - based on Black's code
' ***********************************************************

Dim hsbModeActive
Dim hsEnteredName
Dim hsEnteredDigits(3)
Dim hsCurrentDigit
Dim hsValidLetters
Dim hsCurrentLetter
Dim hsLetterFlash

Sub CheckHighscore()
    Dim tmp
    tmp = Score(1)
    If Score(2)> tmp Then tmp = Score(2)
    If Score(3)> tmp Then tmp = Score(3)
    If Score(4)> tmp Then tmp = Score(4)

    'If tmp > HighScore(1)Then 'add 1 credit for beating the highscore
    '    Credits = Credits + 1
    '    DOF 125, DOFOn
    'End If

    If tmp> HighScore(3) Then
        PlaySound SoundFXDOF("fx_Knocker", 122, DOFPulse, DOFKnocker)
      '  DOF 121, DOFPulse
        HighScore(3) = tmp
        'enter player's name
        HighScoreEntryInit()
    Else
        EndOfBallComplete()
    End If
End Sub

Sub HighScoreEntryInit()
    hsbModeActive = True
	Playsong "bongos"
    'ChangeSong
	PlaySound "hiscore"
    hsLetterFlash = 0

    hsEnteredDigits(0) = " "
    hsEnteredDigits(1) = " "
    hsEnteredDigits(2) = " "
    hsCurrentDigit = 0

    'hsValidLetters = " ABCDEFGHIJKLMNOPQRSTUVWXYZ'<>*+-/=\^0123456789`" ' ` is back arrow
	hsValidLetters = " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789<" ' < is back arrow JP FLEX FIX
    hsCurrentLetter = 1
    DMDFlush()
    HighScoreDisplayNameNow()

    HighScoreFlashTimer.Interval = 250
    HighScoreFlashTimer.Enabled = True
End Sub

Sub EnterHighScoreKey(keycode)
    If keycode = LeftFlipperKey Then
        playsound "fx_Previous"
        hsCurrentLetter = hsCurrentLetter - 1
        if(hsCurrentLetter = 0) then
            hsCurrentLetter = len(hsValidLetters)
        end if
        HighScoreDisplayNameNow()
    End If

    If keycode = RightFlipperKey Then
        playsound "fx_Next"
        hsCurrentLetter = hsCurrentLetter + 1
        if(hsCurrentLetter> len(hsValidLetters) ) then
            hsCurrentLetter = 1
        end if
        HighScoreDisplayNameNow()
    End If

    If keycode = PlungerKey OR keycode = StartGameKey Then
        'if(mid(hsValidLetters, hsCurrentLetter, 1) <> "`") then
		if(mid(hsValidLetters, hsCurrentLetter, 1) <> "<") then 'JP FLEX FIX
            playsound "fx_Enter"
            hsEnteredDigits(hsCurrentDigit) = mid(hsValidLetters, hsCurrentLetter, 1)
            hsCurrentDigit = hsCurrentDigit + 1
            if(hsCurrentDigit = 3) then
                HighScoreCommitName()
            else
                HighScoreDisplayNameNow()
            end if
        else
            playsound "fx_Esc"
            hsEnteredDigits(hsCurrentDigit) = " "
            if(hsCurrentDigit> 0) then
                hsCurrentDigit = hsCurrentDigit - 1
            end if
            HighScoreDisplayNameNow()
        end if
    end if
End Sub

Sub HighScoreDisplayNameNow()
    HighScoreFlashTimer.Enabled = False
    hsLetterFlash = 0
    HighScoreDisplayName()
    HighScoreFlashTimer.Enabled = True
End Sub

Sub HighScoreDisplayName()
    Dim i
    Dim TempTopStr
    Dim TempBotStr

    TempTopStr = "YOUR NAME:"
    dLine(0) = ExpandLine(TempTopStr, 0)
    DMDUpdate 0

    TempBotStr = "    > "
    if(hsCurrentDigit> 0) then TempBotStr = TempBotStr & hsEnteredDigits(0)
    if(hsCurrentDigit> 1) then TempBotStr = TempBotStr & hsEnteredDigits(1)
    if(hsCurrentDigit> 2) then TempBotStr = TempBotStr & hsEnteredDigits(2)

    if(hsCurrentDigit <> 3) then
        if(hsLetterFlash <> 0) then
            TempBotStr = TempBotStr & "_"
        else
            TempBotStr = TempBotStr & mid(hsValidLetters, hsCurrentLetter, 1)
        end if
    end if

    if(hsCurrentDigit <1) then TempBotStr = TempBotStr & hsEnteredDigits(1)
    if(hsCurrentDigit <2) then TempBotStr = TempBotStr & hsEnteredDigits(2)

    TempBotStr = TempBotStr & " <    "
    dLine(1) = ExpandLine(TempBotStr, 1)
    DMDUpdate 1
End Sub

Sub HighScoreFlashTimer_Timer()
    HighScoreFlashTimer.Enabled = False
    hsLetterFlash = hsLetterFlash + 1
    if(hsLetterFlash = 2) then hsLetterFlash = 0
    HighScoreDisplayName()
    HighScoreFlashTimer.Enabled = True
End Sub

Sub HighScoreCommitName()
    HighScoreFlashTimer.Enabled = False
    hsbModeActive = False
    ChangeSong
    hsEnteredName = hsEnteredDigits(0) & hsEnteredDigits(1) & hsEnteredDigits(2)
    if(hsEnteredName = "   ") then
        hsEnteredName = "YOU"
    end if

    HighScoreName(3) = hsEnteredName
    SortHighscore
    EndOfBallComplete()
End Sub

Sub SortHighscore
    Dim tmp, tmp2, i, j
    For i = 0 to 3
        For j = 0 to 2
            If HighScore(j) <HighScore(j + 1) Then
                tmp = HighScore(j + 1)
                tmp2 = HighScoreName(j + 1)
                HighScore(j + 1) = HighScore(j)
                HighScoreName(j + 1) = HighScoreName(j)
                HighScore(j) = tmp
                HighScoreName(j) = tmp2
            End If
        Next
    Next
End Sub

' *************************************************************************
'   JP's Reduced Display Driver Functions (based on script by Black)
' only 5 effects: none, scroll left, scroll right, blink and blinkfast
' 3 Lines, treats all 3 lines as text. 3rd line is just 1 character
' Example format:
' DMD "text1","text2","backpicture", eNone, eNone, eNone, 250, True, "sound"
' Short names:
' dq = display queue
' de = display effect
' *************************************************************************

Const eNone = 0        ' Instantly displayed
Const eScrollLeft = 1  ' scroll on from the right
Const eScrollRight = 2 ' scroll on from the left
Const eBlink = 3       ' Blink (blinks for 'TimeOn')
Const eBlinkFast = 4   ' Blink (blinks for 'TimeOn') at user specified intervals (fast speed)

Const dqSize = 64

Dim dqHead
Dim dqTail
Dim deSpeed
Dim deBlinkSlowRate
Dim deBlinkFastRate

Dim dCharsPerLine(2)
Dim dLine(2)
Dim deCount(2)
Dim deCountEnd(2)
Dim deBlinkCycle(2)

Dim dqText(2, 64)
Dim dqEffect(2, 64)
Dim dqTimeOn(64)
Dim dqbFlush(64)
Dim dqSound(64)

Dim FlexDMD
Dim DMDScene

Sub DMD_Init() 'default/startup values
    If UseFlexDMD Then
        Set FlexDMD = CreateObject("FlexDMD.FlexDMD")
        If Not FlexDMD is Nothing Then
            FlexDMD.TableFile = Table1.Filename & ".vpx"
            FlexDMD.RenderMode = 2
            FlexDMD.Width = 256
            FlexDMD.Height = 64
            FlexDMD.Clear = True
            FlexDMD.GameName = cGameName
            FlexDMD.Run = True
            Set DMDScene = FlexDMD.NewGroup("Scene")
            DMDScene.AddActor FlexDMD.NewImage("Back", "VPX.bkempty")
            DMDScene.GetImage("Back").SetSize FlexDMD.Width, FlexDMD.Height
            For i = 0 to 40
                DMDScene.AddActor FlexDMD.NewImage("Dig" & i, "VPX.dempty&dmd=2")
                'Digits(i).Visible = False
            Next
            'digitgrid.Visible = False
            For i = 0 to 19 ' Top
                    DMDScene.GetImage("Dig" & i).SetBounds 8 + i * 12, 6, 12, 22
                Next
                For i = 20 to 39 ' Bottom
                    DMDScene.GetImage("Dig" & i).SetBounds 8 + (i - 20) * 12, 34, 12, 22
            Next
            FlexDMD.LockRenderThread
            FlexDMD.Stage.AddActor DMDScene
            FlexDMD.UnlockRenderThread
        End If
    End If


'Sub DMD_Init() 'default/startup values
    Dim i, j
    DMDFlush()
    deSpeed = 20
    deBlinkSlowRate = 5
    deBlinkFastRate = 2
    dCharsPerLine(0) = 16 'characters lower line
    dCharsPerLine(1) = 20 'characters top line
    dCharsPerLine(2) = 1  'characters back line
    For i = 0 to 2
        dLine(i) = Space(dCharsPerLine(i) )
        deCount(i) = 0
        deCountEnd(i) = 0
        deBlinkCycle(i) = 0
        dqTimeOn(i) = 0
        dqbFlush(i) = True
        dqSound(i) = ""
    Next
    For i = 0 to 2
        For j = 0 to 64
            dqText(i, j) = ""
            dqEffect(i, j) = eNone
        Next
    Next
    DMD dLine(0), dLine(1), dLine(2), eNone, eNone, eNone, 25, True, ""
End Sub

Sub DMDFlush()
    Dim i
    DMDTimer.Enabled = False
    DMDEffectTimer.Enabled = False
    dqHead = 0
    dqTail = 0
    For i = 0 to 2
        deCount(i) = 0
        deCountEnd(i) = 0
        deBlinkCycle(i) = 0
    Next
End Sub

Sub DMDScore()
    Dim tmp, tmp1, tmp2
    if(dqHead = dqTail) Then
        tmp = RL(0, FormatScore(Score(Currentplayer) ) )
        tmp1 = CL(1, "PLAYER " & CurrentPlayer & "  BALL " & Balls)
        tmp2 = "bkborder"
    End If
    DMD tmp, tmp1, tmp2, eNone, eNone, eNone, 25, True, ""
End Sub

Sub DMDScoreNow
    DMDFlush
    DMDScore
End Sub

Sub DMD(Text0, Text1, Text2, Effect0, Effect1, Effect2, TimeOn, bFlush, Sound)
    if(dqTail <dqSize) Then
        if(Text0 = "_") Then
            dqEffect(0, dqTail) = eNone
            dqText(0, dqTail) = "_"
        Else
            dqEffect(0, dqTail) = Effect0
            dqText(0, dqTail) = ExpandLine(Text0, 0)
        End If

        if(Text1 = "_") Then
            dqEffect(1, dqTail) = eNone
            dqText(1, dqTail) = "_"
        Else
            dqEffect(1, dqTail) = Effect1
            dqText(1, dqTail) = ExpandLine(Text1, 1)
        End If

        if(Text2 = "_") Then
            dqEffect(2, dqTail) = eNone
            dqText(2, dqTail) = "_"
        Else
            dqEffect(2, dqTail) = Effect2
            dqText(2, dqTail) = Text2 'it is always 1 letter in this table
        End If

        dqTimeOn(dqTail) = TimeOn
        dqbFlush(dqTail) = bFlush
        dqSound(dqTail) = Sound
        dqTail = dqTail + 1
        if(dqTail = 1) Then
            DMDHead()
        End If
    End If
End Sub

Sub DMDHead()
    Dim i
    deCount(0) = 0
    deCount(1) = 0
    deCount(2) = 0
    DMDEffectTimer.Interval = deSpeed

    For i = 0 to 2
        Select Case dqEffect(i, dqHead)
            Case eNone:deCountEnd(i) = 1
            Case eScrollLeft:deCountEnd(i) = Len(dqText(i, dqHead) )
            Case eScrollRight:deCountEnd(i) = Len(dqText(i, dqHead) )
            Case eBlink:deCountEnd(i) = int(dqTimeOn(dqHead) / deSpeed)
                deBlinkCycle(i) = 0
            Case eBlinkFast:deCountEnd(i) = int(dqTimeOn(dqHead) / deSpeed)
                deBlinkCycle(i) = 0
        End Select
    Next
    if(dqSound(dqHead) <> "") Then
        PlaySound(dqSound(dqHead) )
    End If
    DMDEffectTimer.Enabled = True
End Sub

Sub DMDEffectTimer_Timer()
    DMDEffectTimer.Enabled = False
    DMDProcessEffectOn()
End Sub

Sub DMDTimer_Timer()
    Dim Head
    DMDTimer.Enabled = False
    Head = dqHead
    dqHead = dqHead + 1
    if(dqHead = dqTail) Then
        if(dqbFlush(Head) = True) Then
            DMDScoreNow()
        Else
            dqHead = 0
            DMDHead()
        End If
    Else
        DMDHead()
    End If
End Sub

Sub DMDProcessEffectOn()
    Dim i
    Dim BlinkEffect
    Dim Temp

    BlinkEffect = False

    For i = 0 to 2
        if(deCount(i) <> deCountEnd(i) ) Then
            deCount(i) = deCount(i) + 1

            select case(dqEffect(i, dqHead) )
                case eNone:
                    Temp = dqText(i, dqHead)
                case eScrollLeft:
                    Temp = Right(dLine(i), dCharsPerLine(i) - 1)
                    Temp = Temp & Mid(dqText(i, dqHead), deCount(i), 1)
                case eScrollRight:
                    Temp = Mid(dqText(i, dqHead), (dCharsPerLine(i) + 1) - deCount(i), 1)
                    Temp = Temp & Left(dLine(i), dCharsPerLine(i) - 1)
                case eBlink:
                    BlinkEffect = True
                    if((deCount(i) MOD deBlinkSlowRate) = 0) Then
                        deBlinkCycle(i) = deBlinkCycle(i) xor 1
                    End If

                    if(deBlinkCycle(i) = 0) Then
                        Temp = dqText(i, dqHead)
                    Else
                        Temp = Space(dCharsPerLine(i) )
                    End If
                case eBlinkFast:
                    BlinkEffect = True
                    if((deCount(i) MOD deBlinkFastRate) = 0) Then
                        deBlinkCycle(i) = deBlinkCycle(i) xor 1
                    End If

                    if(deBlinkCycle(i) = 0) Then
                        Temp = dqText(i, dqHead)
                    Else
                        Temp = Space(dCharsPerLine(i) )
                    End If
            End Select

            if(dqText(i, dqHead) <> "_") Then
                dLine(i) = Temp
                DMDUpdate i
            End If
        End If
    Next

    if(deCount(0) = deCountEnd(0) ) and(deCount(1) = deCountEnd(1) ) and(deCount(2) = deCountEnd(2) ) Then

        if(dqTimeOn(dqHead) = 0) Then
            DMDFlush()
        Else
            if(BlinkEffect = True) Then
                DMDTimer.Interval = 10
            Else
                DMDTimer.Interval = dqTimeOn(dqHead)
            End If

            DMDTimer.Enabled = True
        End If
    Else
        DMDEffectTimer.Enabled = True
    End If
End Sub

Function ExpandLine(TempStr, id) 'id is the number of the dmd line
    If TempStr = "" Then
        TempStr = Space(dCharsPerLine(id) )
    Else
        if(Len(TempStr)> Space(dCharsPerLine(id) ) ) Then
            TempStr = Left(TempStr, Space(dCharsPerLine(id) ) )
        Else
            if(Len(TempStr) <dCharsPerLine(id) ) Then
                TempStr = TempStr & Space(dCharsPerLine(id) - Len(TempStr) )
            End If
        End If
    End If
    ExpandLine = TempStr
End Function

Function FormatScore(ByVal Num) 'it returns a string with commas (as in Black's original font)
    dim i
    dim NumString

    NumString = CStr(abs(Num) )

    For i = Len(NumString) -3 to 1 step -3
        if IsNumeric(mid(NumString, i, 1) ) then
            NumString = left(NumString, i-1) & chr(asc(mid(NumString, i, 1) ) + 48) & right(NumString, Len(NumString) - i)
        end if
    Next
    FormatScore = NumString
End function

Function CL(id, NumString)
    Dim Temp, TempStr
    Temp = (dCharsPerLine(id) - Len(NumString) ) \ 2
    TempStr = Space(Temp) & NumString & Space(Temp)
    CL = TempStr
End Function

Function RL(id, NumString)
    Dim Temp, TempStr
    Temp = dCharsPerLine(id) - Len(NumString)
    TempStr = Space(Temp) & NumString
    RL = TempStr
End Function

'**************
' Update DMD
'**************

Sub DMDUpdate(id)
    Dim digit, value
    If UseFlexDMD Then FlexDMD.LockRenderThread
	Select Case id
		Case 0 'top text line
			For digit = 20 to 35
				DMDDisplayChar mid(dLine(0), digit-19, 1), digit
			Next
		Case 1 'bottom text line
			For digit = 0 to 19
				DMDDisplayChar mid(dLine(1), digit + 1, 1), digit
			Next
		Case 2 ' back image - back animations
			If dLine(2) = "" OR dLine(2) = " " Then dLine(2) = "bkempty"
			DigitsBack(0).ImageA = dLine(2)
			If UseFlexDMD Then DMDScene.GetImage("Back").Bitmap = FlexDMD.NewImage("", "VPX." & dLine(2) & "&dmd=2").Bitmap
	End Select

    If UseFlexDMD Then FlexDMD.UnlockRenderThread
End Sub

Sub DMDDisplayChar(achar, adigit)
    If achar = "" Then achar = " "
    achar = ASC(achar)
    Digits(adigit).ImageA = Chars(achar)
    If UseFlexDMD Then DMDScene.GetImage("Dig" & adigit).Bitmap = FlexDMD.NewImage("", "VPX." & Chars(achar) & "&dmd=2&add").Bitmap
End Sub

'****************************
' JP's new DMD using flashers
'****************************

Dim Digits, DigitsBack, Chars(255), Images(255)

DMDInit

Sub DMDInit
    Dim i
    'If Table1.ShowDT = true then
        Digits = Array(digit0, digit1, digit2, digit3, digit4, digit5, digit6, digit7, digit8, digit9, digit10, digit11,                  _
            digit12, digit13, digit14, digit15, digit16, digit17, digit18, digit19, digit20, digit21, digit22, digit23, digit24, digit25, _
            digit26, digit27, digit28, digit29, digit30, digit31, digit32, digit33, digit34, digit35)
        DigitsBack = Array(digit36)

    For i = 0 to 255:Chars(i)  = "dempty":Next '= "dempty":Images(i) = "dempty":Next

    Chars(32) = "dempty"
    '    Chars(34) = '"
    '    Chars(36) = '$
    '    Chars(39) = ''
    '    Chars(42) = '*
    '    Chars(43) = '+
    '    Chars(45) = '-
    '    Chars(47) = '/
    Chars(48) = "d0"       '0
    Chars(49) = "d1"       '1
    Chars(50) = "d2"       '2
    Chars(51) = "d3"       '3
    Chars(52) = "d4"       '4
    Chars(53) = "d5"       '5
    Chars(54) = "d6"       '6
    Chars(55) = "d7"       '7
    Chars(56) = "d8"       '8
    Chars(57) = "d9"       '9
    Chars(60) = "dless"    '<
    Chars(61) = "dequal"   '=
    Chars(62) = "dgreater" '>
    '   Chars(64) = '@
    Chars(65) = "da" 'A
    Chars(66) = "db" 'B
    Chars(67) = "dc" 'C
    Chars(68) = "dd" 'D
    Chars(69) = "de" 'E
    Chars(70) = "df" 'F
    Chars(71) = "dg" 'G
    Chars(72) = "dh" 'H
    Chars(73) = "di" 'I
    Chars(74) = "dj" 'J
    Chars(75) = "dk" 'K
    Chars(76) = "dl" 'L
    Chars(77) = "dm" 'M
    Chars(78) = "dn" 'N
    Chars(79) = "do" 'O
    Chars(80) = "dp" 'P
    Chars(81) = "dq" 'Q
    Chars(82) = "dr" 'R
    Chars(83) = "ds" 'S
    Chars(84) = "dt" 'T
    Chars(85) = "du" 'U
    Chars(86) = "dv" 'V
    Chars(87) = "dw" 'W
    Chars(88) = "dx" 'X
    Chars(89) = "dy" 'Y
    Chars(90) = "dz" 'Z
    'Chars(91) = "dball" '[
    'Chars(92) = "dcoin" '|
    'Chars(93) = "dpika" ']
    '    Chars(94) = '^
    '    Chars(95) = '_
    Chars(96) = "d0a"  '0.
    Chars(97) = "d1a"  '1.
    Chars(98) = "d2a"  '2.
    Chars(99) = "d3a"  '3.
    Chars(100) = "d4a" '4.
    Chars(101) = "d5a" '5.
    Chars(102) = "d6a" '6.
    Chars(103) = "d7a" '7.
    Chars(104) = "d8a" '8.
    Chars(105) = "d9a" '9
End Sub

'********************************************************************************************
' Only for VPX 10.2 and higher.
' FlashForMs will blink light or a flasher for TotalPeriod(ms) at rate of BlinkPeriod(ms)
' When TotalPeriod done, light or flasher will be set to FinalState value where
' Final State values are:   0=Off, 1=On, 2=Return to previous State
'********************************************************************************************

Sub FlashForMs(MyLight, TotalPeriod, BlinkPeriod, FinalState) 'thanks gtxjoe for the first version

    If TypeName(MyLight) = "Light" Then

        If FinalState = 2 Then
            FinalState = MyLight.State 'Keep the current light state
        End If
        MyLight.BlinkInterval = BlinkPeriod
        MyLight.Duration 2, TotalPeriod, FinalState
    ElseIf TypeName(MyLight) = "Flasher" Then

        Dim steps

        ' Store all blink information
        steps = Int(TotalPeriod / BlinkPeriod + .5) 'Number of ON/OFF steps to perform
        If FinalState = 2 Then                      'Keep the current flasher state
            FinalState = ABS(MyLight.Visible)
        End If
        MyLight.UserValue = steps * 10 + FinalState 'Store # of blinks, and final state

        ' Start blink timer and create timer subroutine
        MyLight.TimerInterval = BlinkPeriod
        MyLight.TimerEnabled = 0
        MyLight.TimerEnabled = 1
        ExecuteGlobal "Sub " & MyLight.Name & "_Timer:" & "Dim tmp, steps, fstate:tmp=me.UserValue:fstate = tmp MOD 10:steps= tmp\10 -1:Me.Visible = steps MOD 2:me.UserValue = steps *10 + fstate:If Steps = 0 then Me.Visible = fstate:Me.TimerEnabled=0:End if:End Sub"
    End If
End Sub

' #####################################
' ###### Flashers flupper #####
' #####################################

Dim TestFlashers, TableRef, FlasherLightIntensity, FlasherFlareIntensity, FlasherOffBrightness

								' *********************************************************************
TestFlashers = 0				' *** set this to 1 to check position of flasher object 			***
Set TableRef = Table1   		' *** change this, if your table has another name       			***
FlasherLightIntensity = 1		' *** lower this, if the VPX lights are too bright (i.e. 0.1)		***
FlasherFlareIntensity = 1		' *** lower this, if the flares are too bright (i.e. 0.1)			***
FlasherOffBrightness = 0.5		' *** brightness of the flasher dome when switched off (range 0-2)	***
								' *********************************************************************

Dim ObjLevel(20), objbase(20), objlit(20), objflasher(20), objlight(20)
Dim tablewidth, tableheight : tablewidth = TableRef.width : tableheight = TableRef.height
'initialise the flasher color, you can only choose from "green", "red", "purple", "blue", "white" and "yellow"
InitFlasher 1, "blue" : InitFlasher 2, "yellow" : InitFlasher 3, "yellow" :
'InitFlasher 4, "green" : InitFlasher 5, "red" : 
InitFlasher 6, "red":InitFlasher 7, "red" : InitFlasher 8, "red" :
InitFlasher 9, "blue" ': InitFlasher 10, "red" : InitFlasher 11, "white" 
' rotate the flasher with the command below (first argument = flasher nr, second argument = angle in degrees)
'RotateFlasher 4,17 : RotateFlasher 5,0 : RotateFlasher 6,90
'RotateFlasher 7,0 : RotateFlasher 8,0 
'RotateFlasher 9,-45 : RotateFlasher 10,90 : RotateFlasher 11,90

Sub InitFlasher(nr, col)
	' store all objects in an array for use in FlashFlasher subroutine
	Set objbase(nr) = Eval("Flasherbase" & nr) : Set objlit(nr) = Eval("Flasherlit" & nr)
	Set objflasher(nr) = Eval("Flasherflash" & nr) : Set objlight(nr) = Eval("Flasherlight" & nr)
	' If the flasher is parallel to the playfield, rotate the VPX flasher object for POV and place it at the correct height
	If objbase(nr).RotY = 0 Then
		objbase(nr).ObjRotZ =  atn( (tablewidth/2 - objbase(nr).x) / (objbase(nr).y - tableheight*1.1)) * 180 / 3.14159
		objflasher(nr).RotZ = objbase(nr).ObjRotZ : objflasher(nr).height = objbase(nr).z + 60
	End If
	' set all effects to invisible and move the lit primitive at the same position and rotation as the base primitive
	objlight(nr).IntensityScale = 0 : objlit(nr).visible = 0 : objlit(nr).material = "Flashermaterial" & nr
	objlit(nr).RotX = objbase(nr).RotX : objlit(nr).RotY = objbase(nr).RotY : objlit(nr).RotZ = objbase(nr).RotZ
	objlit(nr).ObjRotX = objbase(nr).ObjRotX : objlit(nr).ObjRotY = objbase(nr).ObjRotY : objlit(nr).ObjRotZ = objbase(nr).ObjRotZ
	objlit(nr).x = objbase(nr).x : objlit(nr).y = objbase(nr).y : objlit(nr).z = objbase(nr).z
	objbase(nr).BlendDisableLighting = FlasherOffBrightness
	' set the texture and color of all objects
	select case objbase(nr).image
		Case "dome2basewhite" : objbase(nr).image = "dome2base" & col : objlit(nr).image = "dome2lit" & col : 
		Case "ronddomebasewhite" : objbase(nr).image = "ronddomebase" & col : objlit(nr).image = "ronddomelit" & col
		Case "domeearbasewhite" : objbase(nr).image = "domeearbase" & col : objlit(nr).image = "domeearlit" & col
	end select
	If TestFlashers = 0 Then objflasher(nr).imageA = "domeflashwhite" : objflasher(nr).visible = 0 : End If
	select case col
		Case "blue" :   objlight(nr).color = RGB(4,120,255) : objflasher(nr).color = RGB(200,255,255) : objlight(nr).intensity = 5000
		Case "green" :  objlight(nr).color = RGB(12,255,4) : objflasher(nr).color = RGB(12,255,4)
		Case "red" :    objlight(nr).color = RGB(255,32,4) : objflasher(nr).color = RGB(255,32,4)
		Case "purple" : objlight(nr).color = RGB(230,49,255) : objflasher(nr).color = RGB(255,64,255) 
		Case "yellow" : objlight(nr).color = RGB(200,173,25) : objflasher(nr).color = RGB(255,200,50)
		Case "white" :  objlight(nr).color = RGB(255,240,150) : objflasher(nr).color = RGB(100,86,59)
	end select
	objlight(nr).colorfull = objlight(nr).color
	If TableRef.ShowDT and ObjFlasher(nr).RotX = -45 Then 
		objflasher(nr).height = objflasher(nr).height - 20 * ObjFlasher(nr).y / tableheight
		ObjFlasher(nr).y = ObjFlasher(nr).y + 10
	End If
End Sub

Sub RotateFlasher(nr, angle) : angle = ((angle + 360 - objbase(nr).ObjRotZ) mod 180)/30 : objbase(nr).showframe(angle) : objlit(nr).showframe(angle) : End Sub

Sub FlashFlasher(nr)
	If not objflasher(nr).TimerEnabled Then objflasher(nr).TimerEnabled = True : objflasher(nr).visible = 1 : objlit(nr).visible = 1 : End If
	objflasher(nr).opacity = 1000 *  FlasherFlareIntensity * ObjLevel(nr)^2.5
	objlight(nr).IntensityScale = 0.5 * FlasherLightIntensity * ObjLevel(nr)^3
	objbase(nr).BlendDisableLighting =  FlasherOffBrightness + 10 * ObjLevel(nr)^3	
	objlit(nr).BlendDisableLighting = 10 * ObjLevel(nr)^2
	UpdateMaterial "Flashermaterial" & nr,0,0,0,0,0,0,ObjLevel(nr),RGB(255,255,255),0,0,False,True,0,0,0,0 
	ObjLevel(nr) = ObjLevel(nr) * 0.9 - 0.01
	If ObjLevel(nr) < 0 Then objflasher(nr).TimerEnabled = False : objflasher(nr).visible = 0 : objlit(nr).visible = 0 : End If
End Sub

Sub FlasherFlash1_Timer() : FlashFlasher(1) : End Sub 
Sub FlasherFlash2_Timer() : FlashFlasher(2) : End Sub 
Sub FlasherFlash3_Timer() : FlashFlasher(3) : End Sub 
Sub FlasherFlash4_Timer() : FlashFlasher(4) : End Sub 
Sub FlasherFlash5_Timer() : FlashFlasher(5) : End Sub 
Sub FlasherFlash6_Timer() : FlashFlasher(6) : End Sub 
Sub FlasherFlash7_Timer() : FlashFlasher(7) : End Sub
Sub FlasherFlash8_Timer() : FlashFlasher(8) : End Sub
Sub FlasherFlash9_Timer() : FlashFlasher(9) : End Sub
Sub FlasherFlash10_Timer() : FlashFlasher(10) : End Sub
Sub FlasherFlash11_Timer() : FlashFlasher(11) : End Sub

' ###################################
' ###### copy script until here #####
' ###################################

' ***      script for demoing flashers					***
' *** you should not need this in your table			***
' *** in your table start a flash with :				***
' *** ObjLevel(xx) = 1 : FlasherFlashxx_Timer			***
' *** for modulated flashers use 0-1 for ObjLevel(xx)	***

'dim countr : Randomize

'Sub Timer1_Timer
'	If TestFlashers = 0 Then
'		countr = countr + 1 : If Countr > 11 then Countr = 3 : end If
'		If rnd(1) < 0.04 Then
'			PlaySound "fx_relay_on",0,1
'			select case countr
				'case 1 : Objlevel(1) = 1 : FlasherFlash1_Timer
				'case 2 : Objlevel(2) = 1 : FlasherFlash2_Timer
				'case 3 : ObjLevel(3) = 1 : FlasherFlash3_Timer
				'case 4 : ObjLevel(4) = 1 : FlasherFlash4_Timer
				'case 5 : ObjLevel(5) = 1 : FlasherFlash5_Timer
				'case 6 : ObjLevel(6) = 1 : FlasherFlash6_Timer
				'case 7 : ObjLevel(7) = 1 : FlasherFlash7_Timer
				'case 8 : ObjLevel(8) = 1 : FlasherFlash8_Timer
'				case 9 : ObjLevel(9) = 1 : FlasherFlash9_Timer
				'case 10 : ObjLevel(10) = 1 : FlasherFlash10_Timer
				'case 11 : ObjLevel(11) = 1 : FlasherFlash11_Timer
'			end Select
'		End If
'	End If
'end Sub

' ********************************
'   Table info & Attract Mode
' ********************************

Sub ShowTableInfo
    Dim ii
    'info goes in a loop only stopped by the credits and the startkey
    If Score(1) Then
        DMD CL(0, "LAST SCORE"), CL(1, "PLAYER 1" &FormatScore(Score(1) ) ), "", eNone, eNone, eNone, 3000, False, ""
    End If
    If Score(2) Then
        DMD CL(0, "LAST SCORE"), CL(1, "PLAYER 2 " &FormatScore(Score(2) ) ), "", eNone, eNone, eNone, 3000, False, ""
    End If
    If Score(3) Then
        DMD CL(0, "LAST SCORE"), CL(1, "PLAYER 3 " &FormatScore(Score(3) ) ), "", eNone, eNone, eNone, 3000, False, ""
    End If
    If Score(4) Then
        DMD CL(0, "LAST SCORE"), CL(1, "PLAYER 4 " &FormatScore(Score(4) ) ), "", eNone, eNone, eNone, 3000, False, ""
    End If
    DMD CL(0, "GAME OVER"), CL(1, "TRY AGAIN"), "", eNone, eBlink, eNone, 2000, True, ""
    If bFreePlay Then
        DMD "", CL(1, "FREE PLAY"), "", eNone, eNone, eNone, 2000, False, ""
    Else
        If Credits> 0 Then
            DMD CL(0, "CREDITS " & Credits), CL(1, "PRESS START"), "", eNone, eBlink, eNone, 2000, False, ""
        Else
            DMD CL(0, "CREDITS " & Credits), CL(1, "INSERT COIN"), "", eNone, eBlink, eNone, 2000, False, ""
        End If
    End If
	DMD "", "", "intro001", eNone, eNone, eNone, 2000, True, ""
	DMD "", "", "intro002", eNone, eNone, eNone, 1000, True, ""
	DMD "", "", "introof009", eNone, eNone, eNone, 100, True, ""
	DMD "", "", "introof010", eNone, eNone, eNone, 100, True, ""
	DMD "", "", "introof019", eNone, eNone, eNone, 100, True, ""
	DMD "", "", "introof020", eNone, eNone, eNone, 100, True, ""
	DMD "", "", "introof029", eNone, eNone, eNone, 100, True, ""
	DMD "", "", "introof030", eNone, eNone, eNone, 100, True, ""
	DMD "", "", "introof039", eNone, eNone, eNone, 100, True, ""
	DMD "", "", "introof040", eNone, eNone, eNone, 100, True, ""
	DMD "", "", "introof049", eNone, eNone, eNone, 100, True, ""
	DMD "", "", "introof050", eNone, eNone, eNone, 100, True, ""
	DMD "", "", "introof059", eNone, eNone, eNone, 100, True, ""
	DMD "", "", "introof060", eNone, eNone, eNone, 100, True, ""
	DMD "", "", "introof069", eNone, eNone, eNone, 100, True, ""
	DMD "", "", "introof070", eNone, eNone, eNone, 100, True, ""
	DMD "", "", "introof079", eNone, eNone, eNone, 100, True, ""
	DMD "", "", "introof080", eNone, eNone, eNone, 100, True, ""
	DMD "", "", "introof089", eNone, eNone, eNone, 100, True, ""
	DMD "", "", "introof090", eNone, eNone, eNone, 100, True, ""
	DMD "", "", "introof099", eNone, eNone, eNone, 100, True, ""
	DMD "", "", "introof100", eNone, eNone, eNone, 100, True, ""

    DMD CL(0, "HIGHSCORES"), Space(dCharsPerLine(1) ), "", eScrollLeft, eScrollLeft, eNone, 20, False, ""
    DMD CL(0, "HIGHSCORES"), "", "", eBlinkFast, eNone, eNone, 1000, False, ""
    DMD CL(0, "HIGHSCORES"), "1> " &HighScoreName(0) & " " &FormatScore(HighScore(0) ), "", eNone, eScrollLeft, eNone, 2000, False, ""
    DMD "_", "2> " &HighScoreName(1) & " " &FormatScore(HighScore(1) ), "", eNone, eScrollLeft, eNone, 2000, False, ""
    DMD "_", "3> " &HighScoreName(2) & " " &FormatScore(HighScore(2) ), "", eNone, eScrollLeft, eNone, 2000, False, ""
    DMD "_", "4> " &HighScoreName(3) & " " &FormatScore(HighScore(3) ), "", eNone, eScrollLeft, eNone, 2000, False, ""
    DMD Space(dCharsPerLine(0) ), Space(dCharsPerLine(1) ), "", eScrollLeft, eScrollLeft, eNone, 500, False, ""
End Sub

Sub StartAttractMode
	startB2S(1)
    ChangeSong
	Startmist1
    StartLightSeq
    DMDFlush
    ShowTableInfo
End Sub

Sub StopAttractMode
    StopMist
    LightSeqAttract.StopPlay
    DMDScoreNow
End Sub

Sub StartLightSeq()
    'lights sequences
    LightSeqAttract.UpdateInterval = 25
    LightSeqAttract.Play SeqBlinking, , 5, 150
    LightSeqAttract.Play SeqRandom, 40, , 4000
    LightSeqAttract.Play SeqAllOff
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqUpOn, 50, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqDownOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqCircleOutOn, 15, 2
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqUpOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqDownOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqUpOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqDownOn, 25, 1
    LightSeqAttract.UpdateInterval = 10
    LightSeqAttract.Play SeqCircleOutOn, 15, 3
    LightSeqAttract.UpdateInterval = 5
    LightSeqAttract.Play SeqRightOn, 50, 1
    LightSeqAttract.UpdateInterval = 5
    LightSeqAttract.Play SeqLeftOn, 50, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqRightOn, 50, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqLeftOn, 50, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqRightOn, 40, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqLeftOn, 40, 1
    LightSeqAttract.UpdateInterval = 10
    LightSeqAttract.Play SeqRightOn, 30, 1
    LightSeqAttract.UpdateInterval = 10
    LightSeqAttract.Play SeqLeftOn, 30, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqRightOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqLeftOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqRightOn, 15, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqLeftOn, 15, 1
    LightSeqAttract.UpdateInterval = 10
    LightSeqAttract.Play SeqCircleOutOn, 15, 3
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqLeftOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqRightOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqLeftOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqUpOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqDownOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqUpOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqDownOn, 25, 1
    LightSeqAttract.UpdateInterval = 5
    LightSeqAttract.Play SeqStripe1VertOn, 50, 2
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqCircleOutOn, 15, 2
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqStripe1VertOn, 50, 3
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqLeftOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqRightOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqLeftOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqUpOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqDownOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqCircleOutOn, 15, 2
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqStripe2VertOn, 50, 3
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqLeftOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqRightOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqLeftOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqUpOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqDownOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqUpOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqDownOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqStripe1VertOn, 25, 3
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqStripe2VertOn, 25, 3
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqUpOn, 15, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqDownOn, 15, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqUpOn, 15, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqDownOn, 15, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqUpOn, 15, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqDownOn, 15, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqRightOn, 15, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqLeftOn, 15, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqRightOn, 15, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqLeftOn, 15, 1
End Sub

Sub LightSeqAttract_PlayDone()
    StartLightSeq()
End Sub

Sub LightSeqTilt_PlayDone()
    LightSeqTilt.Play SeqAllOff
End Sub

'***********************************************************************
' *********************************************************************
'                     Table Specific Script Starts Here
' *********************************************************************
'***********************************************************************

' droptargets, animations, etc
Sub VPObjects_Init
End Sub

' tables variables and Mode init
Dim HoleBonus, BumperBonus, ALLRampBonus, RampBonus1, RampBonus2, RampBonus3, MulitballBonus, TargetBonus    

Sub Game_Init() 'called at the start of a new game
    Dim i, j
    ChangeSong
	TargetBonus = 0
	bumperHits = 0
	BumperBonus = 0
	ALLRampBonus = 0
	RampBonus1 = 0
	RampBonus2 = 0
	RampBonus3 =0
	MulitballBonus = 0
	'BallInHole = 0
    TurnOffPlayfieldLights()
End Sub

Sub StopEndOfBallMode()     'this sub is called after the last ball is drained
End Sub

Sub ResetNewBallLights()    'turn on or off the needed lights before a new ball is released
    'TurnOffPlayfieldLights
    'li025.State = 1
    'li021.State = 1
    'li022.State = 1
    'li023.State = 1
    'li024.State = 1
	'li033.state = 1
	gi1.state = 1
	gi2.state = 1
	gi3.state = 1
	gi4.state = 1
    SetMultiplierLights False
End Sub

Sub TurnOffPlayfieldLights()
    Dim a
    For each a in aLights
        a.State = 0
    Next
End Sub

' *********************************************************************
'                        Table Object Hit Events
'
' Any target hit Sub should do something like this:
' - play a sound
' - do some physical movement
' - add a score, bonus
' - check some variables/Mode this trigger is a member of
' - set the "LastSwitchHit" variable in case it is needed later
' *********************************************************************

'************
' Slingshots
'************

Dim RStep, Lstep

Sub RightSlingShot_Slingshot
	PlaySound SoundFXDOF("right_slingshot", 105, DOFPulse, DOFContactors), 0,1, 0.05,0.05 '0,1, AudioPan(RightSlingShot), 0.05,0,0,1,AudioFade(RightSlingShot)
    RSling.Visible = 0:RSling1.Visible = 1
    sling1.rotx = 20
    RStep = 0
    RightSlingShot.TimerEnabled = 1
	Score(CurrentPlayer) = Score(CurrentPlayer) + (210*PlayFieldMultiplier(CurrentPlayer))
	gi1.State = 0
	Gi2.State = 0	
End Sub

Sub RightSlingShot_Timer
    Select Case RStep
        Case 1:RSLing1.Visible = 0:RSLing2.Visible = 1:sling1.rotx = 10:gi1.State = 0:Gi2.State = 0
		Case 1:RSLing1.Visible = 0:RSLing2.Visible = 1:sling1.rotx = 5:gi1.State = 0:Gi2.State = 0
        Case 2:RSLing2.Visible = 0:RSLing.Visible = 1:sling1.rotx = 0:gi1.State = 1:Gi2.State = 1:RightSlingShot.TimerEnabled = False
    End Select
    RStep = RStep + 1
End Sub

Sub LeftSlingShot_Slingshot
    PlaySound SoundFXDOF("left_slingshot", 103, DOFPulse, DOFContactors), 0,1, -0.05,0.05 '0,1, AudioPan(LeftSlingShot), 0.05,0,0,1,AudioFade(LeftSlingShot)
    LSling.Visible = 0:LSling1.Visible = 1
    sling2.rotx = 20
	 LStep = 0
    LeftSlingShot.TimerEnabled = 1
	Score(CurrentPlayer) = Score(CurrentPlayer) + (210*PlayFieldMultiplier(CurrentPlayer))
	gi3.State = 0
	Gi4.State = 0
End Sub

Sub LeftSlingShot_Timer
    Select Case LStep
        Case 1:LSLing1.Visible = 0:LSLing2.Visible = 1:sling2.rotx = 10:gi3.State = 0:Gi4.State = 0
        Case 2:LSLing1.Visible = 0:LSLing2.Visible = 1:sling2.rotx = 5:gi3.State = 0:Gi4.State = 0
        Case 3:LSLing2.Visible = 0:LSLing.Visible = 1:sling2.rotx = 0:gi3.State = 1:Gi4.State = 1:LeftSlingShot.TimerEnabled = False
    End Select
    LStep = LStep + 1
End Sub


'*****************
'triggers
'*****************

'**********************upperlanes*********************

sub tup001_hit()
If Tilted Then Exit Sub
	if GameMode = DAYTIME then
        li041.state = 1
        Playsound "triggerupD"
Score(CurrentPlayer) = Score(CurrentPlayer) + (1000*PlayFieldMultiplier(CurrentPlayer))
Checkbfnaf3
	elseif GameMode = NIGHTTIME then
        li015.state = 1
        Playsound "triggerupM"
Score(CurrentPlayer) = Score(CurrentPlayer) + (2000*PlayFieldMultiplier(CurrentPlayer))
Checkbfnaf4
	end if	
end sub

sub tup002_hit()
If Tilted Then Exit Sub
	if GameMode = DAYTIME then
        li042.state = 1
Score(CurrentPlayer) = Score(CurrentPlayer) + (1000*PlayFieldMultiplier(CurrentPlayer))
Checkbfnaf3
        Playsound "triggerupD"
	elseif GameMode = NIGHTTIME then
        li016.state = 1
        Playsound "triggerupM"
Score(CurrentPlayer) = Score(CurrentPlayer) + (2000*PlayFieldMultiplier(CurrentPlayer))
Checkbfnaf4
	end if
end sub

sub tup003_hit()
If Tilted Then Exit Sub
	if GameMode = DAYTIME then
        li043.state = 1
        Playsound "triggerupD"
Score(CurrentPlayer) = Score(CurrentPlayer) + (1000*PlayFieldMultiplier(CurrentPlayer))
Checkbfnaf3
	elseif GameMode = NIGHTTIME then
        li017.state = 1
        Playsound "triggerupM"
Score(CurrentPlayer) = Score(CurrentPlayer) + (2000*PlayFieldMultiplier(CurrentPlayer))
Checkbfnaf4
	end if
end sub

Sub Checkbfnaf3
	If(li041.State = 1) And(li042.State = 1) And(li043.State = 1) Then
    	DMD "", "", "dmd395248", eNone, eNone, eNone, 750, True, "greaty"
    	DMD "", "", "50k", eNone, eNone, eNone, 750, True, ""
		Score(CurrentPlayer) = Score(CurrentPlayer) + (50000*PlayFieldMultiplier(CurrentPlayer))
        li041.State=0
        li042.State=0
        li043.State=0
	End If
End Sub

Sub Checkbfnaf4
	If(li015.State = 1) And(li016.State = 1) And(li017.State = 1) Then
    	DMD "", "", "dmd395248", eNone, eNone, eNone, 750, True, "greaty"
    	DMD "", "", "100k", eNone, eNone, eNone, 750, True, ""
		Score(CurrentPlayer) = Score(CurrentPlayer) + (100000*PlayFieldMultiplier(CurrentPlayer))
        li015.State=0
        li016.State=0
        li017.State=0
	End If
End Sub



'**********************inner/outerlane*********************

Sub TLeftInlane_Hit
If Tilted Then Exit Sub
ObjLevel(3) = 1 : FlasherFlash3_Timer
	if GameMode = DAYTIME then
        LeftInlane.State = 1
        Checkbfnaf1
        PlaySound "inlane2"
	DMD "", "", "10k", eNone, eNone, eNone, 500, True, ""
	Score(CurrentPlayer) = Score(CurrentPlayer) + (10000*PlayFieldMultiplier(CurrentPlayer))
	elseif GameMode = NIGHTTIME then
        li012.State = 1
        Checkbfnaf2
        PlaySound "inlane"
	DMD "", "", "20k", eNone, eNone, eNone, 500, True, ""
	Score(CurrentPlayer) = Score(CurrentPlayer) + (10000*PlayFieldMultiplier(CurrentPlayer))
	end if
End Sub

Sub TLeftOutlane_Hit
If Tilted Then Exit Sub
ObjLevel(3) = 1 : FlasherFlash3_Timer
ObjLevel(9) = 1 : FlasherFlash9_Timer
	if GameMode = DAYTIME then
        LeftOutlane.State = 1
        Checkbfnaf1
        PlaySound "outlane2"
	DMD "", "", "50k", eNone, eNone, eNone, 500, True, ""
	Score(CurrentPlayer) = Score(CurrentPlayer) + (50000*PlayFieldMultiplier(CurrentPlayer))		
	elseif GameMode = NIGHTTIME then
        li011.State = 1
        Checkbfnaf2
        PlaySound "outlane"
	DMD "", "", "100k", eNone, eNone, eNone, 500, True, ""
	Score(CurrentPlayer) = Score(CurrentPlayer) + (100000*PlayFieldMultiplier(CurrentPlayer))
	end if
End Sub

Sub TRightInlane_Hit
If Tilted Then Exit Sub
ObjLevel(2) = 1 : FlasherFlash2_Timer
	if GameMode = DAYTIME then
        RightInlane.State = 1
        Checkbfnaf1
        PlaySound "inlane2"
	DMD "", "", "10k", eNone, eNone, eNone, 500, True, ""
	Score(CurrentPlayer) = Score(CurrentPlayer) + (10000*PlayFieldMultiplier(CurrentPlayer))
	elseif GameMode = NIGHTTIME then
        li013.State = 1
        Checkbfnaf2
        PlaySound "inlane"
	DMD "", "", "20k", eNone, eNone, eNone, 500, True, ""
	Score(CurrentPlayer) = Score(CurrentPlayer) + (10000*PlayFieldMultiplier(CurrentPlayer))
	end if
End Sub

Sub TRightOutlane_Hit
If Tilted Then Exit Sub
ObjLevel(2) = 1 : FlasherFlash2_Timer
ObjLevel(1) = 1 : FlasherFlash1_Timer
	if GameMode = DAYTIME then
        RightOutlane.State = 1
        Checkbfnaf1
        PlaySound "outlane2"
	DMD "", "", "50k", eNone, eNone, eNone, 500, True, ""
	Score(CurrentPlayer) = Score(CurrentPlayer) + (50000*PlayFieldMultiplier(CurrentPlayer))		
	elseif GameMode = NIGHTTIME then
        li014.State = 1
        Checkbfnaf2
        PlaySound "outlane"
	DMD "", "", "100k", eNone, eNone, eNone, 500, True, ""
	Score(CurrentPlayer) = Score(CurrentPlayer) + (100000*PlayFieldMultiplier(CurrentPlayer))
	end if
End Sub

Sub Checkbfnaf1
	If(LeftInlane.State = 1) And(LeftOutlane.State = 1) And(RightInlane.State = 1) And(RightOutlane.State = 1) Then
    	DMD "", "", "dmdfnaf", eNone, eNone, eNone, 750, True, "FNAF"
    	DMD "", "", "100k", eNone, eNone, eNone, 750, True, ""
		Score(CurrentPlayer) = Score(CurrentPlayer) + (100000*PlayFieldMultiplier(CurrentPlayer))
        LeftInlane.State=0
        LeftOutlane.State=0
        RightInlane.State=0
        RightOutlane.State=0	  
	End If
End Sub

Sub Checkbfnaf2
	If(li011.State = 1) And(li012.State = 1) And(li013.State = 1) And(li014.State = 1) Then
    	DMD "", "", "dmdfnaf", eNone, eNone, eNone, 750, True, "FNAF"
    	DMD "", "", "200k", eNone, eNone, eNone, 750, True, ""
		Score(CurrentPlayer) = Score(CurrentPlayer) + (200000*PlayFieldMultiplier(CurrentPlayer))
        li011.State=0
        li012.State=0
        li013.State=0
        li014.State=0	  
	End If
End Sub

Sub Bonuschecker_Hit
if GameMode = DAYTIME then
ObjLevel(2) = 1 : FlasherFlash2_Timer
ObjLevel(1) = 1 : FlasherFlash1_Timer
ObjLevel(3) = 1 : FlasherFlash3_Timer
ObjLevel(9) = 1 : FlasherFlash9_Timer
FlashForMs Flasher010, 1000, 50, 0
FlashForMs Flasher011, 1000, 50, 0
end if
End Sub

'************************** 
'Bumpers 
'************************** 
Dim bumperHits, bmpBall

Sub Bumper001_hit()
If Tilted Then Exit Sub
	Set bmpBall = ActiveBall
    ObjLevel(9) = 1 : FlasherFlash9_Timer
ObjLevel(8) = 1 : FlasherFlash8_Timer
    bumperHits = bumperHits + 1
    If GameMode = DAYTIME Then
        ' Play day sound
        PlaySoundAt SoundFXDOF( "fx_bumper1",107,DOFPulse,DOFContactors), Bumper001
    ElseIf GameMode = NIGHTTIME Then
        ' Play night sound
        PlaySoundAt "fx_Bumper", Bumper001
    End If
    ScoreBumper
    CupcakeShake cball1
    cupcake001_Timer.Enabled = True
End sub

Sub Bumper002_hit()
If Tilted Then Exit Sub
ObjLevel(1) = 1 : FlasherFlash1_Timer
ObjLevel(7) = 1 : FlasherFlash7_Timer
	Set bmpBall = ActiveBall
    bumperHits = bumperHits + 1
    If GameMode = DAYTIME Then
        ' Play day sound
        PlaySoundAt SoundFXDOF( "fx_bumper2",108,DOFPulse,DOFContactors), Bumper002
    ElseIf GameMode = NIGHTTIME Then
        ' Play night sound
        PlaySoundAt "fx_Bumper", Bumper002
    End If
    ScoreBumper
    CupcakeShake cball2
    cupcake002_Timer.Enabled = True
End Sub

Sub Bumper003_hit()
If Tilted Then Exit Sub
ObjLevel(3) = 1 : FlasherFlash3_Timer
ObjLevel(6) = 1 : FlasherFlash6_Timer
	Set bmpBall = ActiveBall
    bumperHits = bumperHits + 1
    If GameMode = DAYTIME Then
        ' Play day sound
        PlaySoundAt SoundFXDOF( "fx_bumper3",109,DOFPulse,DOFContactors), Bumper003
    ElseIf GameMode = NIGHTTIME Then
        ' Play night sound
        PlaySoundAt "fx_Bumper", Bumper003
    End If
    ScoreBumper
    CupcakeShake cball3
    cupcake003_Timer.Enabled = True
End Sub

Sub ScoreBumper()
    Score(CurrentPlayer) = Score(CurrentPlayer) + (2500*PlayFieldMultiplier(CurrentPlayer))
    DMDScoreNow
End Sub
'*****************
'Targets
'*****************

sub Target001_hit()
If Tilted Then Exit Sub
TargetBonus = TargetBonus + 1
	if li006.state = 1 then
    	Score(CurrentPlayer) = Score(CurrentPlayer) + (3000*PlayFieldMultiplier(CurrentPlayer))
        Playsound "NtarBL"
		Checkbfnaf6
	exit sub
	end if
	if GameMode = DAYTIME then
	    li005.state = 1
    	Score(CurrentPlayer) = Score(CurrentPlayer) + (1000*PlayFieldMultiplier(CurrentPlayer))
	    Playsound "targetsF"
		Checkbfnaf5
	ElseIf GameMode = NIGHTTIME then
	    li006.state = 1
		Wall016.image = "plasticsfloor"
		Wall007.image = "plasticsfloor"
    	Score(CurrentPlayer) = Score(CurrentPlayer) + (2000*PlayFieldMultiplier(CurrentPlayer))
        TfnafN = TfnafN + 1
        UpdatefnafclockN
        Playsound "NtarBL"
		Checkbfnaf6
	end if
end sub

sub Target002_hit()
If Tilted Then Exit Sub
TargetBonus = TargetBonus + 1
	if li007.state = 1 then
    	Score(CurrentPlayer) = Score(CurrentPlayer) + (3000*PlayFieldMultiplier(CurrentPlayer))
        Playsound "NtarBR"
		Checkbfnaf6
	    exit sub
	end if
	if GameMode = DAYTIME then
	    li004.state = 1
    	Score(CurrentPlayer) = Score(CurrentPlayer) + (1000*PlayFieldMultiplier(CurrentPlayer))
	    Playsound "targetsF"
		Checkbfnaf5
	elseif GameMode = NIGHTTIME then
	    li007.state = 1
		Wall014.image = "plasticsfloor"
		Wall013.image = "plasticsfloor"
    	Score(CurrentPlayer) = Score(CurrentPlayer) + (2000*PlayFieldMultiplier(CurrentPlayer))
        Playsound "NtarBR"
        TfnafN = TfnafN + 1
        UpdatefnafclockN
		Checkbfnaf6
	end if
end sub

sub Target003_hit()
If Tilted Then Exit Sub
TargetBonus = TargetBonus + 1
	if li008.state = 1 then
    	Score(CurrentPlayer) = Score(CurrentPlayer) + (3000*PlayFieldMultiplier(CurrentPlayer))
        Playsound "NtarBN"	
		Checkbfnaf6
	exit sub
	end if
	if GameMode = DAYTIME then
	    li003.state = 1
    	Score(CurrentPlayer) = Score(CurrentPlayer) + (1000*PlayFieldMultiplier(CurrentPlayer))
	    Playsound "targetsF"
		Checkbfnaf5
	elseif GameMode = NIGHTTIME then
	    li008.state = 1
		Wall015.image = "plasticsfloor"
		Wall010.image = "plasticsfloor"
    	Score(CurrentPlayer) = Score(CurrentPlayer) + (2000*PlayFieldMultiplier(CurrentPlayer))
        TfnafN = TfnafN + 1
        UpdatefnafclockN
        Playsound "NtarBN"
		Checkbfnaf6
	end if
end sub

sub Target004_hit()
If Tilted Then Exit Sub
TargetBonus = TargetBonus + 1
	if li009.state = 1 then
    	Score(CurrentPlayer) = Score(CurrentPlayer) + (3000*PlayFieldMultiplier(CurrentPlayer))
        Playsound "NtarM"
		Checkbfnaf6
	exit sub
	end if
	if GameMode = DAYTIME then
	    li002.state = 1
    	Score(CurrentPlayer) = Score(CurrentPlayer) + (1000*PlayFieldMultiplier(CurrentPlayer))
	    Playsound "targetsF"
		Checkbfnaf5
	elseif GameMode = NIGHTTIME then
	    li009.state = 1
		Wall017.image = "plasticsfloor"
		Wall008.image = "plasticsfloor"
    	Score(CurrentPlayer) = Score(CurrentPlayer) + (2000*PlayFieldMultiplier(CurrentPlayer))
        TfnafN = TfnafN + 1
        UpdatefnafclockN
        Playsound "NtarM"
		Checkbfnaf6
	end if
end sub

sub Target005_hit()
If Tilted Then Exit Sub
TargetBonus = TargetBonus + 1
	if li010.state = 1 then
    	Score(CurrentPlayer) = Score(CurrentPlayer) + (3000*PlayFieldMultiplier(CurrentPlayer))
    Playsound "NtarC"
	Checkbfnaf6
	exit sub
	end if
	if GameMode = DAYTIME then
	    li001.state = 1
    	Score(CurrentPlayer) = Score(CurrentPlayer) + (1000*PlayFieldMultiplier(CurrentPlayer))
	    Playsound "targetsF"
		Checkbfnaf5
	elseif GameMode = NIGHTTIME then
	    li010.state = 1
		Wall39.image = "plasticsfloor"
		Wall30.image = "plasticsfloor"
		Wall31.image = "plasticsfloor"
    	Score(CurrentPlayer) = Score(CurrentPlayer) + (2000*PlayFieldMultiplier(CurrentPlayer))
        TfnafN = TfnafN + 1
        UpdatefnafclockN
        Playsound "NtarC"
		Checkbfnaf6
	end if
end sub

Sub Checkbfnaf5
	If(li001.State = 1) And(li002.State = 1) And(li003.State = 1) And(li004.State = 1) And(li005.State = 1) Then
    	DMD "", "", "dmdfunny", eNone, eNone, eNone, 750, True, "funnyC"
    	DMD "", "", "100k", eNone, eNone, eNone, 750, True, ""
		Score(CurrentPlayer) = Score(CurrentPlayer) + (100000*PlayFieldMultiplier(CurrentPlayer))
        li001.State=0
        li002.State=0
        li003.State=0
        li004.State=0
        li005.State=0	  
	End If
End Sub

Sub Checkbfnaf6
	If(li006.State = 1) And(li007.State = 1) And(li008.State = 1) And(li009.State = 1) And(li010.State = 1)  Then
        li010.State=0
        li009.State=0
        li008.State=0
        li007.State=0
        li006.State=0	  
	End If
End Sub

sub Target006_hit()
TargetBonus = TargetBonus + 1
	if GameMode = DAYTIME then
	    li057.state = 1
    	Score(CurrentPlayer) = Score(CurrentPlayer) + (5000*PlayFieldMultiplier(CurrentPlayer))
	    Playsound "Trobot1"
	elseif GameMode = NIGHTTIME then
	    li056.state = 1
    	Score(CurrentPlayer) = Score(CurrentPlayer) + (10000*PlayFieldMultiplier(CurrentPlayer))
        Playsound "Trobot2"
		Wall026.image = "plasticsfloor"
		Wall025.image = "plasticsfloor"
		Wall024.image = "plasticsfloor"
		Wall027.image = "plasticsfloor"
	end if
end sub

'*****************
'Gates
'*****************
sub Gate_Hit()
If Tilted Then Exit Sub
ObjLevel(2) = 1 : FlasherFlash2_Timer
	playsound "gate1"
	'addscore 3000000
	exit sub
	if Playkitchen = 1 or Playstage = 1 then exit sub
    Ttimey.enabled = true
    GameMode = DAYTIME
End Sub

Sub Gate001_hit()
If Tilted Then Exit Sub
    MultiplierGateHit()
End Sub

Sub Gate002_hit()
If Tilted Then Exit Sub
    MultiplierGateHit()
End Sub

Sub MultiplierGateHit()
    GatesCount(CurrentPlayer) = GatesCount(CurrentPlayer) + 1
    
    if (GatesCount(CurrentPlayer) Mod 2 = 0) And PlayfieldMultiplier(CurrentPlayer) < MaxMultiplier Then
        PlayfieldMultiplier(CurrentPlayer) = PlayfieldMultiplier(CurrentPlayer) + 1
		DMD "", "", "dmdmulti"&PlayfieldMultiplier(CurrentPlayer), eNone, eNone, eNone, 1000, True, "bonus"        
        SetMultiplierLights True
		LightSeqtable.StopPlay
    Else
		LightSeqtable.Play SeqUpOn, 25, 1000
        DMD "", "", "dmdmulti", eNone, eNone, eNone, 1000, True, ""
    End If
End Sub

Sub SetMultiplierLights(Enable)
    Dim max : max = IIf(Enable, PlayfieldMultiplier(CurrentPlayer), MaxMultiplier )
    Dim lState : lState = IIf(Enable, 1, 0)
    Dim i
    For i = 0 to max - 2
        aMultiplierLights(i).State = lState
    Next
End Sub


'*****************
'Spinners
'*****************

sub Spinner001_spin
If Tilted Then Exit Sub
if GameMode = DAYTIME then
		Playsound "swing1"
  DOF 112, DOFPulse
		Score(CurrentPlayer) = Score(CurrentPlayer) + (1000*PlayFieldMultiplier(CurrentPlayer))
	ElseIf GameMode = NIGHTTIME then
		Playsound "swing2"
		Score(CurrentPlayer) = Score(CurrentPlayer) + (10000*PlayFieldMultiplier(CurrentPlayer))
	end if
end sub

sub Spinner002_spin
If Tilted Then Exit Sub
if GameMode = DAYTIME then
		Playsound "swing1"
    DOF 113, DOFPulse
		Score(CurrentPlayer) = Score(CurrentPlayer) + (1000*PlayFieldMultiplier(CurrentPlayer))
	ElseIf GameMode = NIGHTTIME then
		Playsound "swing2"
		Score(CurrentPlayer) = Score(CurrentPlayer) + (10000*PlayFieldMultiplier(CurrentPlayer))
	end if
end sub

'*****************
'Kickers
'*****************
Dim BallInHole

Sub Kicker001_Hit()
BallInHole = BallInHole + 1
Playsound "fx_ballrampdrop"
DOF 116, 1
kicker001.DestroyBall
if GameMode = DAYTIME then
    Ttimey.enabled = False
    end if
    if GameMode = NIGHTTIME then
vpmtimer.addtimer 2000, "SuperVukAddBall '"
exit sub
end if
    if Playstage = 1 then
vpmtimer.addtimer 2000, "SuperVukAddBall '"
exit sub
end if
    if getitemleft = 1 then
vpmtimer.addtimer 2000, "SuperVukAddBall '"
exit sub
end if
StartkitchenSlotmachine
End Sub

Sub SuperVukAddBall()
	If BallInHole> 0 Then
		FlashForMs Flasher011, 1000, 50, 0
        BallInHole = BallInHole - 1
        Kicker001.CreateSizedball BallSize / 2
        'ChangeBallImage
        Playsound SoundFXDOF("fx_popper",114,DOFPulse,DOFContactors)
   DOF 116, 2
        Kicker001.Kick 0,30
        vpmtimer.addtimer 1000, "SuperVukAddBall '" 'to kick other balls if more than 1 ball in the hole
    End If
End Sub

'**************
' SlotMachine kitchen
'**************
'Dim TempBall
Dim SlotAward2, SlotValue2
SlotValue2 = 0

SlotAward2 = Array("dmdk1", "dmdk2", "dmdk3", "dmdk4", "dmdk5")

Sub StartkitchenSlotmachine()
	Playkitchen = 1
	getitemleft = 1
	Dim i
	DMDFlush()
	For i = 0 to 4
		DMD "", "", SlotAward2(i), eNone, eNone, eNone, 50, False, "fx_spinner"
	Next
	vpmtimer.AddTimer 2000, "GiveSlotAwardkitchen '"
'	BSkitchenTokitchen.AddBall Kicker005
End Sub

Dim kitchenSlot:kitchenSlot = 0
Sub GiveSlotAwardkitchen()
	DMDFlush()
	Randomize()
	SlotValue2 = INT(RND * 5) + 1	'randomly pick a mode
	DMD "", "", SlotAward2(SlotValue2-1), eNone, eNone, eNone, 500, True, ""
	Select Case SlotValue2
		Case 1
			SlotValue2 = 1	'pizzaslice
		Case 2
			SlotValue2 = 2	'Milkshake
		Case 3
			SlotValue2 = 4	'Present
		Case 4
			SlotValue2 = 8	'canz
		Case 5
			SlotValue2 = 16	'pizza
	End Select
	'Check if this mode has already been played
	Do While (SlotValue2 AND kitchenSlot) > 0	'We've already done this mode So keep randomly picking one until we get a mode we haven't done yet
		SlotValue2 = INT(RND * 5) + 1
		DMDFlush()
		DMD "", "", SlotAward2(SlotValue2-1), eNone, eNone, eNone, 500, True, ""
		Select Case SlotValue2
			Case 1
				SlotValue2 = 1	'pizzaslice
			Case 2
				SlotValue2 = 2	'Milkshake
			Case 3
				SlotValue2 = 4	'Present
			Case 4
				SlotValue2 = 8	'canz
			Case 5
				SlotValue2 = 16	'pizza
		End Select
	Loop
	Select Case SlotValue2
		Case 1
			vpmTimer.AddTimer 1000, "pizzaslice() '"		'pizzaslice()
		Case 2
			vpmTimer.AddTimer 1000, "kitchenMilkshake() '"		'kitchenMilkshake()
		Case 4
			vpmTimer.AddTimer 1000, "kitchenPresent() '"	'kitchenPresent()
		Case 8
			vpmTimer.AddTimer 1000, "kitchencanz() '"		'kitchencanz()
		Case 16
			vpmTimer.AddTimer 1000, "kitchenpizza() '"		'kitchenpizza()
	End Select
End Sub

Sub kitchenPicker()
	Randomize()
	WheelSpeed = Int(2.5*Rnd+1)
	SpinningWheel.enabled = 1
End Sub

Sub Checkkitchen()
	If kitchenSlot = 31 Then
	DMD "", "", "dmdkitchenc", eNone, eNone, eNone, 750, True, ""
	DMD "", "", "dmdcompleted", eNone, eNone, eNone, 750, True, ""
	DMD "", "", "1mln", eNone, eNone, eNone, 750, True, ""
	Score(CurrentPlayer) = Score(CurrentPlayer) + (1000000*PlayFieldMultiplier(CurrentPlayer))
	kitchenSlot = 0
	li024.state = 0
	li025.state = 0
	li023.state = 0
	li026.state = 0
	li027.state = 0
	End If
End Sub

'********kitchen Pslice mode***************

sub pizzaslice()
'	Status = "Pslice"
	enablePizzaSlice()
'	cBall.Z = 25
'	BSkitchenTokitchen.ExitSol_On
'	itemrotytimer.Enabled = 1
	li024.state = 2
	PizzaSliceChecker = 0
	SuperVukAddBall
end sub

Dim WhichPizzaSlice, PizzaSliceChecker
WhichPizzaSlice = 0
PizzaSliceChecker = 0
sub enablePizzaSlice()
	If PizzaSliceChecker = 7 Then
		CheckBonusPslice()
		Exit Sub
	End If
	Randomize()
	WhichPizzaSlice = INT(RND * 3) + 1
	Select Case WhichPizzaSlice
		Case 3
			WhichPizzaSlice = 4
	End Select
	Do While (WhichPizzaSlice AND PizzaSliceChecker) > 0
		WhichPizzaSlice = INT(RND * 3) + 1
		Select Case WhichPizzaSlice
			Case 3
				WhichPizzaSlice = 4
		End Select
	Loop
	Select Case WhichPizzaSlice
		Case 1
			tSlice001.enabled = 1
			Pslice001.Visible = 1
			Pslice001.X = tSlice001.X
			Pslice001.Y = tSlice001.Y
'			Pslice001.Z= 50
		Case 2
			tSlice002.enabled = 1
			Pslice001.Visible = 1
			Pslice001.X = tSlice002.X
			Pslice001.Y = tSlice002.Y
'			Pslice001.Z= 50
		Case 4
			tSlice003.enabled = 1
			Pslice001.Visible = 1
			Pslice001.X = tSlice003.X
			Pslice001.Y = tSlice003.Y
'			Pslice001.RotY = 35
	End Select
end sub

sub movePslicedown()
	Dim X
	For Each X in Pslices
		X.Visible = 0
	Next
end sub

Sub tSlice001_Hit()
	tSlice001.enabled = 0
	movePslicedown()
	Score(CurrentPlayer) = Score(CurrentPlayer) + (10000*PlayFieldMultiplier(CurrentPlayer))
	Playsound "Pslicehurt"
	PizzaSliceChecker = (PizzaSliceChecker OR 1)
	enablePizzaSlice()
end sub

Sub tSlice002_Hit()
	tSlice002.enabled = 0
	movePslicedown()
	Score(CurrentPlayer) = Score(CurrentPlayer) + (10000*PlayFieldMultiplier(CurrentPlayer))
	Playsound "Pslicehurt"
	PizzaSliceChecker = (PizzaSliceChecker OR 2)
	enablePizzaSlice()
end sub

Sub tSlice003_Hit()
	tSlice003.enabled = 0
	movePslicedown()
	Score(CurrentPlayer) = Score(CurrentPlayer) + (10000*PlayFieldMultiplier(CurrentPlayer))
	Playsound "Pslicehurt"
	PizzaSliceChecker = (PizzaSliceChecker OR 4)
	enablePizzaSlice()
end sub

sub checkbonusPslice()
	If PizzaSliceChecker = 7 then
		DMD "", "", "100k", eNone, eNone, eNone, 1000, True, ""
		Score(CurrentPlayer) = Score(CurrentPlayer) + (100000*PlayFieldMultiplier(CurrentPlayer))
		playsound "won"
		li024.state = 1
		PizzaSliceChecker = 0
		kitchenSlot = kitchenSlot OR 1
		Checkkitchen()
		Ttimey.enabled = True
		Playkitchen = 0
		getitemleft = 0
	end if
end sub

'********kitchen Milkshake mode***************

sub kitchenMilkshake()
	enableMilkshakes()
	li025.state = 2
	MilkshakeChecker = 0
	SuperVukAddBall
end sub

Dim WhichMilkshake, MilkshakeChecker
WhichMilkshake = 0
MilkshakeChecker = 0
sub enableMilkshakes()
	If MilkshakeChecker = 7 Then
		CheckBonusMilkshake()
		Exit Sub
	End If
	Randomize()
	WhichMilkshake = INT(RND * 3) + 1
	Select Case WhichMilkshake
		Case 3
			WhichMilkshake = 4
	End Select
	Do While (WhichMilkshake AND MilkshakeChecker) > 0
		WhichMilkshake = INT(RND * 3) + 1
		Select Case WhichMilkshake
			Case 3
				WhichMilkshake = 4
		End Select
	Loop
	Select Case WhichMilkshake
		Case 1
			tMilkshake001.enabled = 1
			Milkshake001.Visible = 1
			Milkshake001.X = tMilkshake001.X
			Milkshake001.Y = tMilkshake001.Y
		Case 2
			tMilkshake002.enabled = 1
			Milkshake001.Visible = 1
			Milkshake001.X = tMilkshake002.X
			Milkshake001.Y = tMilkshake002.Y
		Case 4
			tMilkshake003.enabled = 1
			Milkshake001.Visible = 1
			Milkshake001.X = tMilkshake003.X
			Milkshake001.Y = tMilkshake003.Y
	End Select
end sub

sub moveMilkshakedown()
	Dim X
	For Each X in Milkshakes
		X.Visible = 0
	Next
end sub

Sub tMilkshake001_Hit()
	tMilkshake001.enabled = 0
	moveMilkshakedown()
	Score(CurrentPlayer) = Score(CurrentPlayer) + (10000*PlayFieldMultiplier(CurrentPlayer))
	Playsound "Milkshakehurt"
	MilkshakeChecker = (MilkshakeChecker OR 1)
	EnableMilkshakes()
end sub

Sub tMilkshake002_Hit()
	tMilkshake002.enabled = 0
	moveMilkshakedown()
	Score(CurrentPlayer) = Score(CurrentPlayer) + (10000*PlayFieldMultiplier(CurrentPlayer))
	Playsound "Milkshakehurt"
	MilkshakeChecker = (MilkshakeChecker OR 2)
	EnableMilkshakes()
end sub

Sub tMilkshake003_Hit()
	tMilkshake003.enabled = 0
	moveMilkshakedown()
	Score(CurrentPlayer) = Score(CurrentPlayer) + (10000*PlayFieldMultiplier(CurrentPlayer))
	Playsound "Milkshakehurt"
	MilkshakeChecker = (MilkshakeChecker OR 4)
	EnableMilkshakes()
end sub

sub checkbonusMilkshake()
	If MilkshakeChecker = 7 then
		DMD "", "", "100k", eNone, eNone, eNone, 1000, True, ""
		Score(CurrentPlayer) = Score(CurrentPlayer) + (100000*PlayFieldMultiplier(CurrentPlayer))
		playsound "won"
		li025.state = 1
		MilkshakeChecker = 0
		kitchenSlot = kitchenSlot OR 2
		Checkkitchen()
		Ttimey.enabled = True
		Playkitchen = 0
		getitemleft = 0
	end if
end sub


'********kitchen Present mode***************

sub kitchenPresent()
'	itemrotytimer.Enabled = 1
	enablePresents()
	li023.state = 2
	PresentChecker = 0
	SuperVukAddBall
end sub

Dim WhichPresent, PresentChecker
WhichPresent = 0
PresentChecker = 0
sub enablePresents()
	If PresentChecker = 7 Then
		CheckBonusPresent()
		Exit Sub
	End If
	Randomize()
	WhichPresent = INT(RND * 3) + 1
	Select Case WhichPresent
		Case 3
			WhichPresent = 4
	End Select
	Do While (WhichPresent AND PresentChecker) > 0
		WhichPresent = INT(RND * 3) + 1
		Select Case WhichPresent
			Case 3
				WhichPresent = 4
		End Select
	Loop
	Select Case WhichPresent
		Case 1
			tPresent001.enabled = 1
			Present001.Visible = 1
			Present001.X = tPresent001.X
			Present001.Y = tPresent001.Y
'			Present001.Z = 30
		Case 2
			tPresent002.enabled = 1
			Present001.Visible = 1
			Present001.X = tPresent002.X
			Present001.Y = tPresent002.Y
'			Present001.Z = 130
		Case 4
			tPresent003.enabled = 1
			Present001.Visible = 1
			Present001.X = tPresent003.X
			Present001.Y = tPresent003.Y
'			Present001.Z = 30
	End Select
end sub

Sub tPresent001_Hit()
	tPresent001.enabled = 0
	movePresentdown()
	Score(CurrentPlayer) = Score(CurrentPlayer) + (10000*PlayFieldMultiplier(CurrentPlayer))
	Playsound "Presenthurt"
	PresentChecker = (PresentChecker OR 1)
	EnablePresents()
end sub

sub MovePresentDown()
	Dim X
	For Each X in Presents
		X.Visible = 0
	Next
end sub

Sub tPresent002_Hit()
	tPresent002.enabled = 0
	MovePresentDown()
	Score(CurrentPlayer) = Score(CurrentPlayer) + (10000*PlayFieldMultiplier(CurrentPlayer))
	Playsound "Presenthurt"
	PresentChecker = (PresentChecker OR 2)
	EnablePresents()
end sub

Sub tPresent003_Hit()
	tPresent003.enabled = 0
	MovePresentDown()
	Score(CurrentPlayer) = Score(CurrentPlayer) + (10000*PlayFieldMultiplier(CurrentPlayer))
	Playsound "Presenthurt"
	PresentChecker = (PresentChecker OR 4)
	EnablePresents()
end sub

sub checkbonusPresent()
	If PresentChecker = 7 then
		DMD "", "", "100k", eNone, eNone, eNone, 1000, True, ""
		Score(CurrentPlayer) = Score(CurrentPlayer) + (100000*PlayFieldMultiplier(CurrentPlayer))
		playsound "won"
		li023.state = 1
		PresentChecker = 0
		kitchenSlot = kitchenSlot OR 4
		Checkkitchen()
		Ttimey.enabled = True
		Playkitchen = 0
		getitemleft = 0
	end if
end sub

'********kitchen canz mode***************

sub kitchencanz()
'	itemrotytimer.Enabled = 1
	enablekitchencanz()
	li027.state = 2
	CanzChecker = 0
	SuperVukAddBall
end sub

Dim WhichCan, CanzChecker
WhichCan = 0
CanzChecker = 0
sub Enablekitchencanz()
	If CanzChecker = 7 Then
		CheckBonusCanz()
		Exit Sub
	End If
	Randomize()
	WhichCan = INT(RND * 3) + 1
	Select Case WhichCan
		Case 3
			WhichCan = 4
	End Select
	Do While (WhichCan AND CanzChecker) > 0
		WhichCan = INT(RND * 3) + 1
		Select Case WhichCan
			Case 3
				WhichCan = 4
		End Select
	Loop
	Select Case WhichCan
		Case 1
			tCanz001.enabled = 1
			Canz001.Visible = 1
			Canz001.X = tCanz001.X
			Canz001.Y = tCanz001.Y
		Case 2
			tCanz002.enabled = 1
			Canz001.Visible = 1
			Canz001.X = tCanz002.X
			Canz001.Y = tCanz002.Y
		Case 4
			tCanz003.enabled = 1
			Canz001.Visible = 1
			Canz001.X = tCanz003.X
			Canz001.Y = tCanz003.Y
	End Select
end sub

Sub tCanz001_Hit()
	tCanz001.enabled = 0
	MoveCanzDown()
	Score(CurrentPlayer) = Score(CurrentPlayer) + (10000*PlayFieldMultiplier(CurrentPlayer))
	Playsound "Canzhurt"
	CanzChecker = (CanzChecker OR 1)
	Enablekitchencanz()
end sub

sub MoveCanzDown()
	Canz001.Visible = 0
end sub

Sub tCanz002_Hit()
	tCanz002.enabled = 0
	MoveCanzDown()
	Score(CurrentPlayer) = Score(CurrentPlayer) + (10000*PlayFieldMultiplier(CurrentPlayer))
	Playsound "Canzhurt"
	CanzChecker = (CanzChecker OR 2)
	Enablekitchencanz()
end sub

Sub tCanz003_Hit()
	tCanz003.enabled = 0
	MoveCanzDown()
	Score(CurrentPlayer) = Score(CurrentPlayer) + (10000*PlayFieldMultiplier(CurrentPlayer))
	Playsound "Canzhurt"
	CanzChecker = (CanzChecker OR 4)
	Enablekitchencanz()
end sub

sub CheckBonusCanz()
	If CanzChecker = 7 then
		DMD "", "", "100k", eNone, eNone, eNone, 1000, True, ""
		Score(CurrentPlayer) = Score(CurrentPlayer) + (100000*PlayFieldMultiplier(CurrentPlayer))
		playsound "won"
		'StopmodeEndofBall()
		li027.state = 1
'		Status = "Normal"
		ChangeSong()
		CanzChecker = 0
		kitchenSlot = kitchenSlot OR 8
		Checkkitchen()
		Ttimey.enabled = True
		Playkitchen = 0
		getitemleft = 0
	end if
end sub

'********kitchen pizza mode***************

sub kitchenpizza()
'	itemrotytimer.Enabled = 1
	Enablepizza()
	li026.state = 2
	PizzaChecker = 0
	SuperVukAddBall
end sub

Dim WhichPizza, PizzaChecker
WhichPizza = 0
PizzaChecker = 0
sub Enablepizza()
	If PizzaChecker = 7 Then
		CheckBonusPizza()
		Exit Sub
	End If
	Randomize()
	WhichPizza = INT(RND * 3) + 1
	Select Case WhichPizza
		Case 3
			WhichPizza = 4
	End Select
	Do While (WhichPizza AND PizzaChecker) > 0
		WhichPizza = INT(RND * 3) + 1
		Select Case WhichPizza
			Case 3
				WhichPizza = 4
		End Select
	Loop
	Select Case WhichPizza
		Case 1
			TPizza001.enabled = 1
			Pizza001.Visible = 1
			Pizza001.X = TPizza001.X
			Pizza001.Y = TPizza001.Y
		Case 2
			TPizza002.enabled = 1
			Pizza001.Visible = 1
			Pizza001.X = TPizza002.X
			Pizza001.Y = TPizza002.Y
		Case 4
			TPizza003.enabled = 1
			Pizza001.Visible = 1
			Pizza001.X = TPizza003.X
			Pizza001.Y = TPizza003.Y
	End Select
end sub

Sub tPizza001_Hit()
	tPizza001.enabled = 0
	MovePizzaDown()
	Score(CurrentPlayer) = Score(CurrentPlayer) + (10000*PlayFieldMultiplier(CurrentPlayer))
	Playsound "Pizzahurt"
	PizzaChecker = (PizzaChecker OR 1)
	Enablepizza()
end sub

sub MovePizzaDown()
	Dim X
	For Each X in pizzas
		X.Visible = 0
	Next
end sub

Sub tPizza002_Hit()
	tPizza002.enabled = 0
	MovePizzaDown()
	Score(CurrentPlayer) = Score(CurrentPlayer) + (10000*PlayFieldMultiplier(CurrentPlayer))
	Playsound "Pizzahurt"
	PizzaChecker = (PizzaChecker OR 2)
	Enablepizza()
end sub

Sub tPizza003_Hit()
	tPizza003.enabled = 0
	MovePizzaDown()
	Score(CurrentPlayer) = Score(CurrentPlayer) + (10000*PlayFieldMultiplier(CurrentPlayer))
	Playsound "Pizzahurt"
	PizzaChecker = (PizzaChecker OR 4)
	Enablepizza()
end sub

sub checkbonusPizza()
	If PizzaChecker = 7 then
		DMD "", "", "100k", eNone, eNone, eNone, 1000, True, ""
		Score(CurrentPlayer) = Score(CurrentPlayer) + (100000*PlayFieldMultiplier(CurrentPlayer))
		playsound "won"
		li026.state = 1
'		Status = "Normal"
		PizzaChecker = 0
		kitchenSlot = kitchenSlot OR 16
		Checkkitchen()
		Ttimey.enabled = True
		Playkitchen = 0
		getitemleft = 0
	end if
end sub

'*******************************************************************************************

Dim BallInHole1

Sub Kicker002_Hit()
BallInHole1 = BallInHole1 + 1
Playsound "fx_ballrampdrop"
DOF 117, 1
kicker002.DestroyBall
if GameMode = DAYTIME then
    Ttimey.enabled = False
end if
    if GameMode = NIGHTTIME then
vpmtimer.addtimer 2000, "SuperVukAddBall1 '"
exit sub
end if
    if Playkitchen = 1 then
vpmtimer.addtimer 2000, "SuperVukAddBall1 '"
exit sub
end if
    if getitemright = 1 then
vpmtimer.addtimer 2000, "SuperVukAddBall1 '"
exit sub
end if
StartStageSlotmachine
End Sub

Sub SuperVukAddBall1()
	If BallInHole1> 0 Then
		FlashForMs Flasher010, 1000, 50, 0
        BallInHole1 = BallInHole1 - 1
        Kicker002.CreateSizedball BallSize / 2
        Playsound SoundFXDOF("fx_popper",115,DOFPulse,DOFContactors)
        DOF 117, 2
        Kicker002.Kick 0,30
        vpmtimer.addtimer 1000, "SuperVukAddBall1 '" 
    end If
End Sub

'**************
' SlotMachine stage
'**************
'Dim TempBall
Dim SlotAward, SlotValue
SlotValue = 0

SlotAward = Array("dmds1", "dmds2", "dmds3", "dmds4", "dmds5")

Sub StartStageSlotmachine()
	Playstage = 1
	getitemright = 1
	Dim i
	DMDFlush()
	For i = 0 to 4
		DMD "", "", SlotAward(i), eNone, eNone, eNone, 50, False, "fx_spinner"
	Next
	vpmtimer.AddTimer 2000, "GiveSlotAwardstage '"
'	BSstageTostage.AddBall Kicker005
End Sub

Dim stageSlot:stageSlot = 0
Sub GiveSlotAwardstage()
	DMDFlush()
	Randomize()
	SlotValue = INT(RND * 5) + 1	'randomly pick a mode
	DMD "", "", SlotAward(SlotValue-1), eNone, eNone, eNone, 500, True, ""
	Select Case SlotValue
		Case 1
			SlotValue = 1	'Guitar
		Case 2
			SlotValue = 2	'Monitor
		Case 3
			SlotValue = 4	'Flashlight
		Case 4
			SlotValue = 8	'voicerecorder
		Case 5
			SlotValue = 16	'Microphone
	End Select
	'Check if this mode has already been played
	Do While (SlotValue AND stageSlot) > 0	'We've already done this mode So keep randomly picking one until we get a mode we haven't done yet
		SlotValue = INT(RND * 5) + 1
		DMDFlush()
		DMD "", "", SlotAward(SlotValue-1), eNone, eNone, eNone, 500, True, ""
		Select Case SlotValue
			Case 1
				SlotValue = 1	'Guitar
			Case 2
				SlotValue = 2	'Monitor
			Case 3
				SlotValue = 4	'Flashlight
			Case 4
				SlotValue = 8	'voicerecorder
			Case 5
				SlotValue = 16	'Microphone
		End Select
	Loop
	Select Case SlotValue
		Case 1
			vpmTimer.AddTimer 1000, "Guitar() '"		'Guitar()
		Case 2
			vpmTimer.AddTimer 1000, "stageMonitor() '"		'stageMonitor()
		Case 4
			vpmTimer.AddTimer 1000, "stageFlashlight() '"	'stageFlashlight()
		Case 8
			vpmTimer.AddTimer 1000, "stagevoicerecorder() '"		'stagevoicerecorder()
		Case 16
			vpmTimer.AddTimer 1000, "stageMicrophone() '"		'stageMicrophone()
	End Select
End Sub

Sub Checkstage()
	If stageSlot = 31 Then
	DMD "", "", "dmdstagec", eNone, eNone, eNone, 750, True, ""
	DMD "", "", "dmdcompleted", eNone, eNone, eNone, 750, True, ""
	DMD "", "", "1mln", eNone, eNone, eNone, 750, True, ""
	Score(CurrentPlayer) = Score(CurrentPlayer) + (1000000*PlayFieldMultiplier(CurrentPlayer))
	stageSlot = 0
	li020.state = 0
	li018.state = 0
	li021.state = 0
	li022.state = 0
	li019.state = 0
	End If
End Sub

'********stage Guitar mode***************

sub Guitar()
	enableGuitar()
'	itemrotytimer.Enabled = 1
	li020.state = 2
	GuitarChecker = 0
	SuperVukAddBall1
end sub

Dim WhichGuitar, GuitarChecker
WhichGuitar = 0
GuitarChecker = 0
sub enableGuitar()
	If GuitarChecker = 7 Then
		CheckBonusGuitar()
		Exit Sub
	End If
	Randomize()
	WhichGuitar = INT(RND * 3) + 1
	Select Case WhichGuitar
		Case 3
			WhichGuitar = 4
	End Select
	Do While (WhichGuitar AND GuitarChecker) > 0
		WhichGuitar = INT(RND * 3) + 1
		Select Case WhichGuitar
			Case 3
				WhichGuitar = 4
		End Select
	Loop
	Select Case WhichGuitar
		Case 1
			tGuitar001.enabled = 1
			Guitar001.Visible = 1
			Guitar001.X = tGuitar001.X
			Guitar001.Y = tGuitar001.Y
		Case 2
			tGuitar002.enabled = 1
			Guitar001.Visible = 1
			Guitar001.X = tGuitar002.X
			Guitar001.Y = tGuitar002.Y
		Case 4
			tGuitar003.enabled = 1
			Guitar001.Visible = 1
			Guitar001.X = tGuitar003.X
			Guitar001.Y = tGuitar003.Y
	End Select
end sub

sub moveGuitardown()
	Dim X
	For Each X in Guitars
		X.Visible = 0
	Next
end sub

Sub tGuitar001_Hit()
	tGuitar001.enabled = 0
	moveGuitardown()
	Score(CurrentPlayer) = Score(CurrentPlayer) + (10000*PlayFieldMultiplier(CurrentPlayer))
	Playsound "Guitarhurt"
	GuitarChecker = (GuitarChecker OR 1)
	enableGuitar()
end sub

Sub tGuitar002_Hit()
	tGuitar002.enabled = 0
	moveGuitardown()
	Score(CurrentPlayer) = Score(CurrentPlayer) + (10000*PlayFieldMultiplier(CurrentPlayer))
	Playsound "Guitarhurt"
	GuitarChecker = (GuitarChecker OR 2)
	enableGuitar()
end sub

Sub tGuitar003_Hit()
	tGuitar003.enabled = 0
	moveGuitardown()
	Score(CurrentPlayer) = Score(CurrentPlayer) + (10000*PlayFieldMultiplier(CurrentPlayer))
	Playsound "Guitarhurt"
	GuitarChecker = (GuitarChecker OR 4)
	enableGuitar()
end sub

sub CheckBonusGuitar()
	If GuitarChecker = 7 then
		DMD "", "", "100k", eNone, eNone, eNone, 1000, True, ""
		Score(CurrentPlayer) = Score(CurrentPlayer) + (100000*PlayFieldMultiplier(CurrentPlayer))
		playsound "won"
		li020.state = 1
		GuitarChecker = 0
		stageSlot = stageSlot OR 1
		Checkstage()
		Ttimey.enabled = True
		Playstage = 0
		getitemright = 0
	end if
end sub

'********stage Monitor mode***************

sub stageMonitor()
	enableMonitors()
	li018.state = 2
	MonitorChecker = 0
	SuperVukAddBall1
end sub

Dim WhichMonitor, MonitorChecker
WhichMonitor = 0
MonitorChecker = 0
sub enableMonitors()
	If MonitorChecker = 7 Then
		CheckBonusMonitor()
		Exit Sub
	End If
	Randomize()
	WhichMonitor = INT(RND * 3) + 1
	Select Case WhichMonitor
		Case 3
			WhichMonitor = 4
	End Select
	Do While (WhichMonitor AND MonitorChecker) > 0
		WhichMonitor = INT(RND * 3) + 1
		Select Case WhichMonitor
			Case 3
				WhichMonitor = 4
		End Select
	Loop
	Select Case WhichMonitor
		Case 1
			tMonitor001.enabled = 1
			Monitor001.Visible = 1
			Monitor001.X = tMonitor001.X
			Monitor001.Y = tMonitor001.Y
		Case 2
			tMonitor002.enabled = 1
			Monitor001.Visible = 1
			Monitor001.X = tMonitor002.X
			Monitor001.Y = tMonitor002.Y
		Case 4
			tMonitor003.enabled = 1
			Monitor001.Visible = 1
			Monitor001.X = tMonitor003.X
			Monitor001.Y = tMonitor003.Y
	End Select
end sub

sub moveMonitordown()
	Dim X
	For Each X in Monitors
		X.Visible = 0
	Next
end sub

Sub tMonitor001_Hit()
	tMonitor001.enabled = 0
	moveMonitordown()
	Score(CurrentPlayer) = Score(CurrentPlayer) + (10000*PlayFieldMultiplier(CurrentPlayer))
	Playsound "Monitorhurt"
	MonitorChecker = (MonitorChecker OR 1)
	EnableMonitors()
end sub

Sub tMonitor002_Hit()
	tMonitor002.enabled = 0
	moveMonitordown()
	Score(CurrentPlayer) = Score(CurrentPlayer) + (10000*PlayFieldMultiplier(CurrentPlayer))
	Playsound "Monitorhurt"
	MonitorChecker = (MonitorChecker OR 2)
	EnableMonitors()
end sub

Sub tMonitor003_Hit()
	tMonitor003.enabled = 0
	moveMonitordown()
	Score(CurrentPlayer) = Score(CurrentPlayer) + (10000*PlayFieldMultiplier(CurrentPlayer))
	Playsound "Monitorhurt"
	MonitorChecker = (MonitorChecker OR 4)
	EnableMonitors()
end sub

sub checkbonusMonitor()
	If MonitorChecker = 7 then
		DMD "", "", "100k", eNone, eNone, eNone, 1000, True, ""
		Score(CurrentPlayer) = Score(CurrentPlayer) + (100000*PlayFieldMultiplier(CurrentPlayer))
		playsound "won"
		li018.state = 1
		MonitorChecker = 0
		stageSlot = stageSlot OR 2
		Checkstage()
		Ttimey.enabled = True
		Playstage = 0
		getitemright = 0
	end if
end sub

'********stage Flashlight mode***************

sub stageFlashlight()
	enableFlashlights()
	li021.state = 2
	FlashlightChecker = 0
	SuperVukAddBall1
end sub

Dim WhichFlashlight, FlashlightChecker
WhichFlashlight = 0
FlashlightChecker = 0
sub enableFlashlights()
	If FlashlightChecker = 7 Then
		CheckBonusFlashlight()
		Exit Sub
	End If
	Randomize()
	WhichFlashlight = INT(RND * 3) + 1
	Select Case WhichFlashlight
		Case 3
			WhichFlashlight = 4
	End Select
	Do While (WhichFlashlight AND FlashlightChecker) > 0
		WhichFlashlight = INT(RND * 3) + 1
		Select Case WhichFlashlight
			Case 3
				WhichFlashlight = 4
		End Select
	Loop
	Select Case WhichFlashlight
		Case 1
			tFlashlight001.enabled = 1
			Flashlight001.Visible = 1
			Flashlight001.X = tFlashlight001.X
			Flashlight001.Y = tFlashlight001.Y
		Case 2
			tFlashlight002.enabled = 1
			Flashlight001.Visible = 1
			Flashlight001.X = tFlashlight002.X
			Flashlight001.Y = tFlashlight002.Y
		Case 4
			tFlashlight003.enabled = 1
			Flashlight001.Visible = 1
			Flashlight001.X = tFlashlight003.X
			Flashlight001.Y = tFlashlight003.Y
	End Select
end sub

Sub tFlashlight001_Hit()
	tFlashlight001.enabled = 0
	moveFlashlightdown()
	Score(CurrentPlayer) = Score(CurrentPlayer) + (10000*PlayFieldMultiplier(CurrentPlayer))
	Playsound "Flashlighthurt"
	FlashlightChecker = (FlashlightChecker OR 1)
	EnableFlashlights()
end sub

sub MoveFlashlightDown()
	Dim X
	For Each X in Flashlights
		X.Visible = 0
	Next
end sub

Sub tFlashlight002_Hit()
	tFlashlight002.enabled = 0
	MoveFlashlightDown()
	Score(CurrentPlayer) = Score(CurrentPlayer) + (10000*PlayFieldMultiplier(CurrentPlayer))
	Playsound "Flashlighthurt"
	FlashlightChecker = (FlashlightChecker OR 2)
	EnableFlashlights()
end sub

Sub tFlashlight003_Hit()
	tFlashlight003.enabled = 0
	MoveFlashlightDown()
	Score(CurrentPlayer) = Score(CurrentPlayer) + (10000*PlayFieldMultiplier(CurrentPlayer))
	Playsound "Flashlighthurt"
	FlashlightChecker = (FlashlightChecker OR 4)
	EnableFlashlights()
end sub

sub checkbonusFlashlight()
	If FlashlightChecker = 7 then
		DMD "", "", "100k", eNone, eNone, eNone, 1000, True, ""
		Score(CurrentPlayer) = Score(CurrentPlayer) + (100000*PlayFieldMultiplier(CurrentPlayer))
		playsound "won"
		li021.state = 1
		FlashlightChecker = 0
		stageSlot = stageSlot OR 4
		Checkstage()
		Ttimey.enabled = True
		Playstage = 0
		getitemright = 0
	end if
end sub

'********stage voicerecorder mode***************

sub stagevoicerecorder()
	enablestagevoicerecorder()
	li022.state = 2
	voicerecorderChecker = 0
	SuperVukAddBall1
end sub

Dim Whichvoicerecorder, voicerecorderChecker
Whichvoicerecorder = 0
voicerecorderChecker = 0
sub Enablestagevoicerecorder()
	If voicerecorderChecker = 7 Then
		CheckBonusvoicerecorder()
		Exit Sub
	End If
	Randomize()
	WhichCan = INT(RND * 3) + 1
	Select Case WhichCan
		Case 3
			WhichCan = 4
	End Select
	Do While (WhichCan AND voicerecorderChecker) > 0
		WhichCan = INT(RND * 3) + 1
		Select Case WhichCan
			Case 3
				WhichCan = 4
		End Select
	Loop
	Select Case WhichCan
		Case 1
			tvoicerecorder001.enabled = 1
			voicerecorder001.Visible = 1
			voicerecorder001.X = tvoicerecorder001.X
			voicerecorder001.Y = tvoicerecorder001.Y
		Case 2
			tvoicerecorder002.enabled = 1
			voicerecorder001.Visible = 1
			voicerecorder001.X = tvoicerecorder002.X
			voicerecorder001.Y = tvoicerecorder002.Y
		Case 4
			tvoicerecorder003.enabled = 1
			voicerecorder001.Visible = 1
			voicerecorder001.X = tvoicerecorder003.X
			voicerecorder001.Y = tvoicerecorder003.Y
	End Select
end sub

Sub tvoicerecorder001_Hit()
	tvoicerecorder001.enabled = 0
	MovevoicerecorderDown()
	Score(CurrentPlayer) = Score(CurrentPlayer) + (10000*PlayFieldMultiplier(CurrentPlayer))
	Playsound "voicerecorderhurt"
	voicerecorderChecker = (voicerecorderChecker OR 1)
	Enablestagevoicerecorder()
end sub

sub MovevoicerecorderDown()
	voicerecorder001.Visible = 0
end sub

Sub tvoicerecorder002_Hit()
	tvoicerecorder002.enabled = 0
	MovevoicerecorderDown()
	Score(CurrentPlayer) = Score(CurrentPlayer) + (10000*PlayFieldMultiplier(CurrentPlayer))
	Playsound "voicerecorderhurt"
	voicerecorderChecker = (voicerecorderChecker OR 2)
	Enablestagevoicerecorder()
end sub

Sub tvoicerecorder003_Hit()
	tvoicerecorder003.enabled = 0
	MovevoicerecorderDown()
	Score(CurrentPlayer) = Score(CurrentPlayer) + (10000*PlayFieldMultiplier(CurrentPlayer))
	Playsound "voicerecorderhurt"
	voicerecorderChecker = (voicerecorderChecker OR 4)
	Enablestagevoicerecorder()
end sub

sub CheckBonusvoicerecorder()
	If voicerecorderChecker = 7 then
		DMD "", "", "100k", eNone, eNone, eNone, 1000, True, ""
		Score(CurrentPlayer) = Score(CurrentPlayer) + (100000*PlayFieldMultiplier(CurrentPlayer))
		playsound "won"
'		StopmodeEndofBall()
		li022.state = 1
'		Status = "Normal"
		ChangeSong()
		voicerecorderChecker = 0
		stageSlot = stageSlot OR 8
		Checkstage()
		Ttimey.enabled = True
		Playstage = 0
		getitemright = 0
	end if
end sub

'********stage Microphone mode***************

sub stageMicrophone()
	EnableMicrophone()
	li019.state = 2
	MicrophoneChecker = 0
	SuperVukAddBall1
end sub

Dim WhichMicrophone, MicrophoneChecker
WhichMicrophone = 0
MicrophoneChecker = 0
sub EnableMicrophone()
	If MicrophoneChecker = 7 Then
		CheckBonusMicrophone()
		Exit Sub
	End If
	Randomize()
	WhichMicrophone = INT(RND * 3) + 1
	Select Case WhichMicrophone
		Case 3
			WhichMicrophone = 4
	End Select
	Do While (WhichMicrophone AND MicrophoneChecker) > 0
		WhichMicrophone = INT(RND * 3) + 1
		Select Case WhichMicrophone
			Case 3
				WhichMicrophone = 4
		End Select
	Loop
	Select Case WhichMicrophone
		Case 1
			TMicrophone001.enabled = 1
			Microphone001.Visible = 1
			Microphone001.X = TMicrophone001.X
			Microphone001.Y = TMicrophone001.Y
		Case 2
			TMicrophone002.enabled = 1
			Microphone001.Visible = 1
			Microphone001.X = TMicrophone002.X
			Microphone001.Y = TMicrophone002.Y
		Case 4
			TMicrophone003.enabled = 1
			Microphone001.Visible = 1
			Microphone001.X = TMicrophone003.X
			Microphone001.Y = TMicrophone003.Y
	End Select
end sub

Sub tMicrophone001_Hit()
	tMicrophone001.enabled = 0
	MoveMicrophoneDown()
	Score(CurrentPlayer) = Score(CurrentPlayer) + (10000*PlayFieldMultiplier(CurrentPlayer))
	Playsound "Microphonehurt"
	MicrophoneChecker = (MicrophoneChecker OR 1)
	EnableMicrophone()
end sub

sub MoveMicrophoneDown()
	Dim X
	For Each X in Microphones
		X.Visible = 0
	Next
end sub

Sub tMicrophone002_Hit()
	tMicrophone002.enabled = 0
	MoveMicrophoneDown()
	Score(CurrentPlayer) = Score(CurrentPlayer) + (10000*PlayFieldMultiplier(CurrentPlayer))
	Playsound "Microphonehurt"
	MicrophoneChecker = (MicrophoneChecker OR 2)
	EnableMicrophone()
end sub

Sub tMicrophone003_Hit()
	tMicrophone003.enabled = 0
	MoveMicrophoneDown()
	Score(CurrentPlayer) = Score(CurrentPlayer) + (10000*PlayFieldMultiplier(CurrentPlayer))
	Playsound "Microphonehurt"
	MicrophoneChecker = (MicrophoneChecker OR 4)
	EnableMicrophone()
end sub

sub checkbonusMicrophone()
	If MicrophoneChecker = 7 then
		DMD "", "", "100k", eNone, eNone, eNone, 1000, True, ""
		Score(CurrentPlayer) = Score(CurrentPlayer) + (100000*PlayFieldMultiplier(CurrentPlayer))
		playsound "won"
		li019.state = 1
		MicrophoneChecker = 0
		stageSlot = stageSlot OR 16
		Checkstage()
		Ttimey.enabled = True
		Playstage = 0
		getitemright = 0
	end if
end sub

sub resetallfornewgamy
tSlice001.enabled = False
tSlice002.enabled = False
tSlice003.enabled = False
Pslice001.Visible = False
tMilkshake001.enabled = False
tMilkshake002.enabled = False
tMilkshake003.enabled = False
Milkshake001.Visible = False
tPresent001.enabled = False
tPresent002.enabled = False
tPresent003.enabled = False
Present001.Visible = False
tCanz001.enabled = False
tCanz002.enabled = False
tCanz003.enabled = False
Canz001.Visible = False
TPizza001.enabled = False
TPizza002.enabled = False
TPizza003.enabled = False
Pizza001.Visible = False
tGuitar001.enabled = False
tGuitar002.enabled = False
tGuitar003.enabled = False
Guitar001.Visible = False
tMonitor001.enabled = False
tMonitor002.enabled = False
tMonitor003.enabled = False
Monitor001.Visible = False 
tFlashlight001.enabled = False
tFlashlight002.enabled = False
tFlashlight003.enabled = False
Flashlight001.Visible = False
tvoicerecorder001.enabled = False
tvoicerecorder002.enabled = False
tvoicerecorder003.enabled = False
voicerecorder001.Visible = False
TMicrophone001.enabled = False
TMicrophone002.enabled = False
TMicrophone003.enabled = False
Microphone001.Visible = False
end sub

'*******************************************************************************************

'*****************
'digital clock FNAF + flasher nights
'*****************

sub Ttimey_timer
	timeupy
end sub

Sub timeupy
	Tfnaf = Tfnaf + 1
	Updatefnafclock
end sub

Sub Updatefnafclock
    Select Case Tfnaf
        Case 1:Fnafclock.Image="7uur":monitoro002.Image="monitor3b":monitoro001.Image="monitor3a"
        Case 2:Fnafclock.Image= "8uur":monitoro002.Image="monitor1a":monitoro001.Image="monitor1"
        Case 3:Fnafclock.Image="9uur":monitoro002.Image="monitor3b":monitoro001.Image="monitor3a"
        Case 4:Fnafclock.Image= "10uur":monitoro002.Image="monitor1a":monitoro001.Image="monitor1"
        Case 5:Fnafclock.Image="11uur":monitoro002.Image="monitor3b":monitoro001.Image="monitor3a"
        Case 6:Fnafclock.Image="12uur":monitoro002.Image="monitor1a":monitoro001.Image="monitor1"
        Case 7:Fnafclock.Image="13uur":monitoro002.Image="monitor3b":monitoro001.Image="monitor3a"
        Case 8:Fnafclock.Image="14uur":monitoro002.Image="monitor1a":monitoro001.Image="monitor1"
        Case 9:Fnafclock.Image="15uur":monitoro002.Image="monitor3b":monitoro001.Image="monitor3a"
        Case 10:Fnafclock.Image="16uur":monitoro002.Image="monitor1a":monitoro001.Image="monitor1"
        Case 11:Fnafclock.Image="17uur":monitoro002.Image="monitor3b":monitoro001.Image="monitor3a"
        Case 12:Fnafclock.Image="18uur":monitoro002.Image="monitor1a":monitoro001.Image="monitor1"
        Case 13:Fnafclock.Image="19uur":monitoro002.Image="monitor3b":monitoro001.Image="monitor3a"
        Case 14:Fnafclock.Image="20uur":monitoro002.Image="monitor1a":monitoro001.Image="monitor1"
        Case 15:Fnafclock.Image="21uur":monitoro002.Image="monitor3b":monitoro001.Image="monitor3a"
        Case 16:Fnafclock.Image="22uur":monitoro002.Image="monitor1a":monitoro001.Image="monitor1"
        Case 17:Fnafclock.Image="23uur":monitoro002.Image="monitor3b":monitoro001.Image="monitor3a"
        Case 18:Fnafclock.Image="24uur":ChangeMode NIGHTTIME
    End Select
end sub

Sub UpdatefnafclockN
    Select Case TfnafN
        Case 1:Fnafclock.Image= "2uur"
        Case 2:Fnafclock.Image= "3uur"
        Case 3:Fnafclock.Image= "4uur"
        Case 4:Fnafclock.Image= "5uur"
        Case 5:Fnafclock.Image=	"6uur":enabledaytimer:ChangeMode DAYTIME
    End Select
end sub

sub enabledaytimer
DMD "", "", "dmdnight", eNone, eNone, eNone, 750, True, "nightover"
DMD "", "", "200k", eNone, eNone, eNone, 750, True, ""
Score(CurrentPlayer) = Score(CurrentPlayer) + (200000*PlayFieldMultiplier(CurrentPlayer))
NightTimer.Enabled = False
Tfnaf = 0
TfnafN = 0
Tnights = Tnights + 1
Updatenight
Ttimey.enabled = True
UpdateMusicNow
end Sub

sub Updatenight
	select case Tnights
        Case 1:Fnight1
        Case 2:Fnight2
        Case 3:Fnight3
        Case 4:Fnight4
        Case 5:Fnight5
        Case 6:Fnight6
        Case 7:Fnight7
        Case 8:Fnight8
        Case 9:Fnight9
        Case 10:Fnight10
        Case 11:Fnight11
        Case 12:Fnight12
        Case 13:Fnight13
        Case 14:Fnight14
        Case 15:Fnight15
        Case 16:Fnight16
        Case 17:Fnight17
        Case 18:Fnight18
        Case 19:Fnight19
        Case 20:Fnight20
    End Select
end sub


Sub Fnight0
nights002.ImageA ="n0"
nights001.ImageA ="n0"
end sub

Sub Fnight1
nights002.ImageA ="n0"
nights001.ImageA ="n1"
end sub

Sub Fnight2
nights002.ImageA ="n0"
nights001.ImageA ="n2"
end sub

Sub Fnight3
nights002.ImageA ="n0"
nights001.ImageA ="n3"
end sub

Sub Fnight4
nights002.ImageA ="n0"
nights001.ImageA ="n4"
end sub

Sub Fnight5
nights002.ImageA ="n0"
nights001.ImageA ="n5"
end sub

Sub Fnight6
nights002.ImageA ="n0"
nights001.ImageA ="n6"
end sub

Sub Fnight7
nights002.ImageA ="n0"
nights001.ImageA ="n7"
end sub

Sub Fnight8
nights002.ImageA ="n0"
nights001.ImageA ="n8"
end sub

Sub Fnight9
nights002.ImageA ="n0"
nights001.ImageA ="n9"
end sub

Sub Fnight10
nights002.ImageA ="n1"
nights001.ImageA ="n0"
end sub

Sub Fnight11
nights002.ImageA ="n1"
nights001.ImageA ="n1"
end sub

Sub Fnight12
nights002.ImageA ="n1"
nights001.ImageA ="n2"
end sub

Sub Fnight13
nights002.ImageA ="n1"
nights001.ImageA ="n3"
end sub

Sub Fnight14
nights002.ImageA ="n1"
nights001.ImageA ="n4"
end sub

Sub Fnight15
nights002.ImageA ="n1"
nights001.ImageA ="n5"
end sub

Sub Fnight16
nights002.ImageA ="n1"
nights001.ImageA ="n6"
end sub

Sub Fnight17
nights002.ImageA ="n1"
nights001.ImageA ="n7"
end sub

Sub Fnight18
nights002.ImageA ="n1"
nights001.ImageA ="n8"
end sub

Sub Fnight19
nights002.ImageA ="n1"
nights001.ImageA ="n9"
end sub

Sub Fnight20
nights002.ImageA ="n2"
nights001.ImageA ="n0"
end sub


Sub ChangeMode(Mode)	
    Select Case Mode
        Case NIGHTTIME:
			startB2S(3)
            Ttimey.enabled = False
			Tmonitory.Enabled = True
			Wall39.image = "plasticsDark"
			Wall015.image = "plasticsDark"
			Wall014.image = "plasticsDark"
			Wall013.image = "plasticsDark"
			Wall010.image = "plasticsDark"
			Wall017.image = "plasticsDark"
			Wall008.image = "plasticsDark"
			Wall008.image = "plasticsDark"
			Wall016.image = "plasticsDark"
			Wall30.image = "plasticsDark"
			Wall31.image = "plasticsDark"
			Wall007.image = "plasticsDark"
			Wall026.image = "plasticsDark"
			Wall025.image = "plasticsDark"
			Wall024.image = "plasticsDark"
			Wall027.image = "plasticsDark"
            GrabBall
            StopSong
            PlaySound "nighttime"
            vpmTimer.AddTimer 3000,"alldisapear ''"
            vpmTimer.AddTimer 8850,"changetonight ''"
            vpmTimer.AddTimer 15000,"changeclocky ''"
            vpmTimer.AddTimer 15600,"nightsongy ''"
            StartNightTimer.Enabled = True
        Case DAYTIME:
			startB2S(2)
            NightTimer.Enabled = False
			Tmonitory.Enabled = False
				Table1.ColorGradeImage = "ColorGradeLUT256x16_1to1"
			TfnafN = 0
			Wall39.image = "plasticsfloor"
			Wall015.image = "plasticsfloor"
			Wall014.image = "plasticsfloor"
			Wall013.image = "plasticsfloor"
			Wall010.image = "plasticsfloor"
			Wall017.image = "plasticsfloor"
			Wall008.image = "plasticsfloor"
			Wall008.image = "plasticsfloor"
			Wall016.image = "plasticsfloor"
			Wall30.image = "plasticsfloor"
			Wall31.image = "plasticsfloor"
			Wall007.image = "plasticsfloor"
			Wall026.image = "plasticsfloor"
			Wall025.image = "plasticsfloor"
			Wall024.image = "plasticsfloor"
			Wall027.image = "plasticsfloor"
            changetoday
    End Select

    GameMode = Mode
End Sub
Sub StartNightTimer_Timer()
    Me.Enabled = False
    StartNight
End Sub
Sub StartNight()
    Dim nTime : nTime = RandomNumber(1,5)
    Dim nLen
    Select Case nTime
        Case 1:
            nLen = 20000
        Case 2:
            nLen = 40000
        Case 3:
            nLen = 60000
        Case 4:
            nLen = 80000
        Case 5:
            nLen = 100000
    End Select

    NightTimer.Interval = nLen
    NightTimer.Enabled = True
    ReleaseBall
End Sub

Sub Tmonitory_Timer
countr11 = countr11 + 1 : If Countr11 > 2 then Countr11 = 1 : end If 
select case countr11
			case 1 :monitoro002.Image="monitor2a":monitoro001.Image="monitor2a"
			case 2 :monitoro002.Image="monitor2b":monitoro001.Image="monitor2b"
			end Select
End Sub

Sub NightTimer_Timer()
    ' Night is up and you LOSE );
    Me.Enabled = False
    Scare
End Sub

Sub Scare()
    Dim scareNum : scareNum = RandomNumber(1,13)
    PlaySound "scare_"&scareNum
	loadrandomscare
    TiltTable
End Sub

Sub loadrandomscare
dim govdnum : govdnum=RandomNumber(1,5)
select case govdnum
			case 1 :Startscare1
			case 2 :Startscare2
			case 3 :Startscare3
			case 4 :Startscare4
			case 5 :Startscare5
end select
end sub

sub changeclocky
Fnafclock.Image="1uur"
end sub

sub nightsongy
PlaySong "night"
end sub

sub alldisapear
    cupcake001.visible = false
    cupcake002.visible = false
    cupcake003.visible = false
	balloonboy.Visible = false
	chica.Visible = false 
	bonnie.Visible = false
	frazbear.Visible = false
	marrionette.Visible = false
end sub

sub resetscare
side1timer.Enabled = False
side2timer.Enabled = False
side3timer.Enabled = False
side4timer.Enabled = False
side5timer.Enabled = False
Flasher001.visible=false
end sub


'**************scare on flasher*****************

Dim side1Pos, side1a
side1a = Array("scr_1", "scr_1a")

Sub Startscare1
    side1Pos = 0
    side1timer.Enabled = 1
	Flasher001.visible=true
End Sub

Sub side1timer_Timer
    'debug.print fire1pos
    Flasher001.ImageA = side1a(side1Pos)
    side1Pos = (side1Pos + 1) MOD 2
End Sub

'**************

Dim side2Pos, side2a
side2a = Array("scr_2", "scr_2a")

Sub Startscare2
    side2Pos = 0
    side2timer.Enabled = 1
	Flasher001.visible=true
End Sub

Sub side2timer_Timer
    'debug.print fire1pos
    Flasher001.ImageA = side2a(side2Pos)
    side2Pos = (side2Pos + 1) MOD 2
End Sub

'**************

Dim side3Pos, side3a
side3a = Array("scr_3", "scr_3a")

Sub Startscare3
    side3Pos = 0
    side3timer.Enabled = 1
	Flasher001.visible=true
End Sub

Sub side3timer_Timer
    'debug.print fire1pos
    Flasher001.ImageA = side3a(side3Pos)
    side3Pos = (side3Pos + 1) MOD 2
End Sub

'**************

Dim side4Pos, side4a
side4a = Array("scr_4", "scr_4a")

Sub Startscare4
    side4Pos = 0
    side4timer.Enabled = 1
	Flasher001.visible=true
End Sub

Sub side4timer_Timer
    'debug.print fire1pos
    Flasher001.ImageA = side4a(side4Pos)
    side4Pos = (side4Pos + 1) MOD 2
End Sub

'**************

Dim side5Pos, side5a
side5a = Array("scr_5", "scr_5a")

Sub Startscare5
    side5Pos = 0
    side5timer.Enabled = 1
	Flasher001.visible=true
End Sub

Sub side5timer_Timer
    'debug.print fire1pos
    Flasher001.ImageA = side5a(side5Pos)
    side5Pos = (side5Pos + 1) MOD 2
End Sub

'******************************
' Cupcake wobbles
'******************************
Sub CupcakeShake(cball)
	cball.velx = cball.velx + bmpBall.velx*pMod
	cball.vely = cball.vely + bmpBall.vely*pMod
End Sub

Function WobbleCupcake(cupcake, ball, kicker)
	Dim rmod
	ball.Vely = ball.VelY-ngrav
    rmod = (cupcake.z+265.5)/265*.6				'.6 is a 60% modifier for ratio of ball movement to cupcake movement
	cupcake.rotx = 90 + (kicker.y - ball.y)*rmod
	cupcake.roty = (ball.x - kicker.x)*rmod

End Function

Sub cupcake001_Timer_Timer()
	If GameMode = DAYTIME Then
		WobbleCupcake cupcake001, cBall1, ckicker001
	Else
		WobbleCupcake cupcakeN001, cBall1, ckicker001
	End If

End Sub

Sub cupcake002_Timer_Timer()
	If GameMode = DAYTIME Then
		WobbleCupcake cupcake002, cBall2, ckicker002
	Else
		WobbleCupcake cupcakeN002, cBall2, ckicker002
	End If

End Sub

Sub cupcake003_Timer_Timer()
	If GameMode = DAYTIME Then
		WobbleCupcake cupcake003, cBall3, ckicker003
	Else
		WobbleCupcake cupcakeN003, cBall3, ckicker003
	End If

End Sub

Dim mMagnet1, mMagnet2, mMagnet3, cBall1, cBall2, cBall3
Dim ngrav, ngravmod, pslope, nslope, slopemod, pMod
Sub WobbleMagnetInit()
	pslope = Table1.SlopeMin +((Table1.SlopeMax - Table1.SlopeMin) * Table1.GlobalDifficulty)
	nslope = pslope
	slopemod = pslope + nslope
	ngravmod = 60/CupcakeWobbleInterval
	ngrav = slopemod * .0905 * Table1.Gravity / ngravmod
	pMod = .15					'percentage of hit power transfered to captive wobble ball
End Sub
Sub WobbleMagnet001_Init
	 Set mMagnet1 = new cvpmMagnet
	 With mMagnet1
		.InitMagnet WobbleMagnet001, 2
		.Size = 100
		.CreateEvents mMagnet1
		.MagnetOn = True
	 End With
    
    Set cBall1 = ckicker001.createball:cBall1.Visible = 0:ckicker001.Kick 0,0:mMagnet1.addball cball1
End Sub

Sub WobbleMagnet002_Init
	 Set mMagnet2 = new cvpmMagnet
	 With mMagnet2
		.InitMagnet WobbleMagnet002, 2
		.Size = 100
		.CreateEvents mMagnet2
		.MagnetOn = True
	 End With
    

	Set cBall2 = ckicker002.createball:cBall2.Visible = 0:ckicker002.Kick 0,0:mMagnet2.addball cball2
End Sub

Sub WobbleMagnet003_Init
	 Set mMagnet3 = new cvpmMagnet
	 With mMagnet3
		.InitMagnet WobbleMagnet003, 2
		.Size = 100
		.CreateEvents mMagnet3
		.MagnetOn = True
	 End With

	Set cBall3 = ckicker003.createball:cBall3.Visible = 0:ckicker003.Kick 0,0:mMagnet3.addball cball3
End Sub
'******************************
'change primatives on Table1
'******************************
Sub GrabBall
	mModeMagnet.MagnetOn = True
	mModeMagnet.Update
End Sub

Sub ReleaseBall
	mModeMagnet.MagnetOn = False
	mModeMagnet.Update
End Sub

sub changetoday
	StopMist
'	Fnafclock.Image="6uur"
'	Tfnaf = 0
    cupcake001.visible = true
    cupcake002.visible = true
    cupcake003.visible = true
    cupcakeN003.visible = false
    cupcakeN002.visible = false
    cupcakeN001.visible = false
frazbearN001.visible=false
chicaN001.visible=false
bonnyN001.visible=false
marrionetteN001.visible=false
	balloon.Visible = false
	balloonboy.Visible = true
	chica.Visible = true 
	bonnie.Visible = true
	frazbear.Visible = true
	marrionette.Visible = true
    target001.Image = "tf"
    target002.Image = "tu"
    target003.Image = "tn"
    target004.Image = "tn"
    target005.Image = "ty"
	li006.state = 0
	li007.state = 0
	li008.state = 0
	li009.state = 0
	li010.state = 0
	li011.state = 0
	li012.state = 0
	li013.state = 0
	li014.state = 0
	li015.state = 0
	li016.state = 0
	li017.state = 0
	li056.state = 0
	Spinner001.image = "spnl"
	Spinner002.image = "spnr"
end sub

sub changetonight
	table1.ColorGradeImage = "-70"
    Startmist1
    cupcake001.visible = false
    cupcake002.visible = false
    cupcake003.visible = false
    cupcakeN003.visible = true
    cupcakeN002.visible = true
    cupcakeN001.visible = true
frazbearN001.visible=true
chicaN001.visible=true
bonnyN001.visible=true
marrionetteN001.visible=true
	balloon.Visible = true
	balloonboy.Visible = false
	chica.Visible = false 
	bonnie.Visible = false
	frazbear.Visible = false
	marrionette.Visible = false
    target001.Image = "tnn"
    target002.Image = "ti"
    target003.Image = "tg"
    target004.Image = "th"
    target005.Image = "tt"
	li005.state = 0
	li004.state = 0
	li003.state = 0
	li002.state = 0
	li001.state = 0
	li057.state = 0
	LeftOutlane.state = 0
	LeftInlane.state = 0
	RightInlane.state = 0
	RightOutlane.state = 0
	li041.state = 0
	li042.state = 0
	li043.state = 0
	Spinner001.image = "spnNl"
	Spinner002.image = "spnNr"
end sub

Function IIf(bClause, sTrue, sFalse)
    Dim bExpr: bExpr = False
    On Error Resume Next
    bExpr = CBool(bClause)
    On Error Goto 0

    If bExpr Then
        If IsObject(sTrue) Then
            Set IIf = sTrue
        Else 
            IIf = sTrue
        End If
    Else
        If IsObject(sFalse) Then
            Set IIf = sFalse
        Else 
            IIf = sFalse
        End If
    End If
End Function

Function RandomNumber(min,max)
    Randomize()
	RandomNumber = Int(Rnd()*(max-min+1))+min     ' Sets a random number between min AND max
End Function

'******************************
'night mist
'******************************
Dim mist1Pos, mist1a
mist1a = Array("m1", "m2", "m3", "m4", "m5", "m6", "m7", "m8", "m9", "m10", "m11", "m12", "m13", "m14", "m15", "m16", "m17", "m18", "m19", "m20", "m21", "m22", "m23", "m24", "m25", "m26",_ 
"m27", "m28", "m29", "m30", "m29", "m28", "m27", "m26", "m25", "m24", "m23", "m22", "m21", "m20", "m19", "m18", "m17", "m16", "m15", "m14", "m13", "m12", "m11", "m10", "m9", "m8", "m7",_
"m6", "m5", "m4", "m3", "m2")
Sub Startmist1
    mist1Pos = 0
	Flasher002.Visible = True
    mist1timer.Enabled = 1
End Sub

Sub StopMist
    Flasher002.Visible = False
    mist1timer.Enabled = 0
End Sub

Sub mist1timer_Timer
    'debug.print fire1pos
    Flasher002.ImageA = mist1a(mist1Pos)
    mist1Pos = (mist1Pos + 1) MOD 58
End Sub

'----------------------------------------------------------------------------
'		Full Table Magnet
'
' This is HEAVILY based on the Magnet within core.vbs.  However, this will
' stop the balls in place, instead of pulling them to the center of the 
' trigger
'----------------------------------------------------------------------------
Class cvpmTableMagnet
	Private mEnabled, mBalls, mTrigger
	Public X, Y, Solenoid

	Private Sub Class_Initialize
		Solenoid = 0 : mEnabled = False
		Set mBalls = New cvpmDictionary
	End Sub

	Private Property Let NeedUpdate(aEnabled) : vpmTimer.EnableUpdate Me, True, aEnabled : End Property

	Public Sub InitMagnet(aTrigger, aStrength)
		Dim tmp
		If vpmIsArray(aTrigger) Then Set tmp = aTrigger(0) Else Set tmp = aTrigger
		X = tmp.X : Y = tmp.Y : vpmTimer.InitTimer tmp, True
		If IsArray(aTrigger) Then mTrigger = aTrigger Else Set mTrigger = aTrigger
	End Sub

	Public Sub CreateEvents(aName)
		If vpmCheckEvent(aName, Me) Then
			vpmBuildEvent mTrigger, "Hit", aName & ".AddBall ActiveBall"
			vpmBuildEvent mTrigger, "UnHit", aName & ".RemoveBall ActiveBall"
		End If
	End Sub

	Public Property Let MagnetOn(aEnabled) 
		mEnabled = aEnabled 
		Dim obj
		If (mEnabled) Then
			' Save all the ball X/Y/VelX/VelY when magnet is turned on
			For Each obj In mBalls.Keys
				mBalls.Item(obj).X = obj.X
				mBalls.Item(obj).Y = obj.Y
				mBalls.Item(obj).VelX = obj.VelX
				mBalls.Item(obj).VelY = obj.VelY
			Next
		Else
			' Restore the ball VelX/VelY when magnet is turned off
			For Each obj In mBalls.Keys
				obj.VelX = mBalls.Item(obj).VelX
				obj.VelY = mBalls.Item(obj).VelY
			Next
		End If
	End Property
	Public Property Get MagnetOn
		If Solenoid > 0 Then MagnetOn = Controller.Solenoid(Solenoid) Else MagnetOn = mEnabled
	End Property

	Public Sub AddBall(aBall)
		With mBalls
			If .Exists(aBall) Then 
				.Item(aBall).Count = .Item(aBall).Count + 1 
			Else 
				Dim aItem : Set aItem = new cpvmTableMagnetBall
				 With aItem
					.Count = 1
					.X = aBall.X
					.Y = aBall.Y
				 End With
				.Add aBall, aItem
			End If
			NeedUpdate = True
		End With
	End Sub

	Public Sub RemoveBall(aBall)
		With mBalls
			If .Exists(aBall) Then .Item(aBall).Count = .Item(aBall).Count - 1 : If .Item(aBall).Count <= 0 Then .Remove aBall
			NeedUpdate = (.Count > 0)
		End With
	End Sub

	Public Property Get Balls : Balls = mBalls.Keys : End Property

	Public Sub Update
		Dim obj
		If MagnetOn Then
			On Error Resume Next
			For Each obj In mBalls.Keys
				If obj.X < 0 Or Err Then
					mBalls.Remove obj 
				Else 
					obj.VelX = 0
					obj.VelY = 0
					obj.X = mBalls.Item(obj).X
					obj.Y = mBalls.Item(obj).Y
				End If
			Next
			On Error Goto 0
		End If
	End Sub
End Class
Class cpvmTableMagnetBall
	Private mCount, mX, mY, mVelX, mVelY

	Private Sub Class_Initialize
		mCount = 0 : mX = 0 : mY = 0 : mVelX = 0 : mVelY = 0
	End Sub

	Public Property Let Count(aCount) : mCount = aCount : End Property
	Public Property Get Count : Count = mCount : End Property

	Public Property Let X(aX) : mX = aX : End Property
	Public Property Get X : X = mX : End Property

	Public Property Let Y(aY) : mY = aY : End Property
	Public Property Get Y : Y = mY : End Property

	Public Property Let VelX(aVelX) : mVelX = aVelX : End Property
	Public Property Get VelX : VelX = mVelX : End Property

	Public Property Let VelY(aVelY) : mVelY = aVelY : End Property
	Public Property Get VelY : VelY = mVelY : End Property
End Class

'******************************
'changing tunnel
'******************************

'****************************************************BALL 1*****************************************************

sub forshotball1
B1.image="cadeau2"
B2.image="cadeau"
B3.image="cadeau2"
B4.image="cadeau"
B5.image="cadeau2"
B6.image="cadeau"
B7.image="cadeau2"
B8.image="cadeau"
B9.image="cadeau2"
B10.image="cadeau"
B11.image="cadeau2"
B12.image="cadeau"
B13.image="cadeau2"
B14.image="cadeau"
B15.image="cadeau2"
end sub

sub forshotball1a
B1.image="cadeau"
B2.image="cadeau2"
B3.image="cadeau"
B4.image="cadeau2"
B5.image="cadeau"
B6.image="cadeau2"
B7.image="cadeau"
B8.image="cadeau2"
B9.image="cadeau"
B10.image="cadeau2"
B11.image="cadeau"
B12.image="cadeau2"
B13.image="cadeau"
B14.image="cadeau2"
B15.image="cadeau"
end sub

Sub Tchglanes1_Timer
countr = countr + 1 : If Countr > 2 then Countr = 1 : end If 
select case countr
			case 1 :forshotball1 
			case 2 :forshotball1a 
			end Select
End Sub

Sub Tchglanes1a_Timer
countr2 = countr2 + 1 : If Countr2 > 15 then forshotball1b 'Countr35 = 1 : end If 
select case countr2
			case 1 : B1.image="cadeau":B2.image="cadeauW":B3.image="cadeauW":B4.image="cadeauW":B5.image="cadeauW":B6.image="cadeauW":B7.image="cadeauW":B8.image="cadeauW":B9.image="cadeauW":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 2 : B1.image="cadeau":B2.image="cadeau":B3.image="cadeauW":B4.image="cadeauW":B5.image="cadeauW":B6.image="cadeauW":B7.image="cadeauW":B8.image="cadeauW":B9.image="cadeauW":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 3 : B1.image="cadeau":B2.image="cadeau":B3.image="cadeau":B4.image="cadeauW":B5.image="cadeauW":B6.image="cadeauW":B7.image="cadeauW":B8.image="cadeauW":B9.image="cadeauW":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 4 : B1.image="cadeau":B2.image="cadeau":B3.image="cadeau":B4.image="cadeau":B5.image="cadeauW":B6.image="cadeauW":B7.image="cadeauW":B8.image="cadeauW":B9.image="cadeauW":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 5 : B1.image="cadeau":B2.image="cadeau":B3.image="cadeau":B4.image="cadeau":B5.image="cadeau":B6.image="cadeauW":B7.image="cadeauW":B8.image="cadeauW":B9.image="cadeauW":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 6 : B1.image="cadeau":B2.image="cadeau":B3.image="cadeau":B4.image="cadeau":B5.image="cadeau":B6.image="cadeau":B7.image="cadeauW":B8.image="cadeauW":B9.image="cadeauW":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 7 : B1.image="cadeau":B2.image="cadeau":B3.image="cadeau":B4.image="cadeau":B5.image="cadeau":B6.image="cadeau":B7.image="cadeau":B8.image="cadeauW":B9.image="cadeauW":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 8 : B1.image="cadeau":B2.image="cadeau":B3.image="cadeau":B4.image="cadeau":B5.image="cadeau":B6.image="cadeau":B7.image="cadeau":B8.image="cadeau":B9.image="cadeauW":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 9 : B1.image="cadeau":B2.image="cadeau":B3.image="cadeau":B4.image="cadeau":B5.image="cadeau":B6.image="cadeau":B7.image="cadeau":B8.image="cadeau":B9.image="cadeau":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 10 : B1.image="cadeau":B2.image="cadeau":B3.image="cadeau":B4.image="cadeau":B5.image="cadeau":B6.image="cadeau":B7.image="cadeau":B8.image="cadeau":B9.image="cadeau":B10.image="cadeau":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 11 : B1.image="cadeau":B2.image="cadeau":B3.image="cadeau":B4.image="cadeau":B5.image="cadeau":B6.image="cadeau":B7.image="cadeau":B8.image="cadeau":B9.image="cadeau":B10.image="cadeau":B11.image="cadeau":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 12 : B1.image="cadeau":B2.image="cadeau":B3.image="cadeau":B4.image="cadeau":B5.image="cadeau":B6.image="cadeau":B7.image="cadeau":B8.image="cadeau":B9.image="cadeau":B10.image="cadeau":B11.image="cadeau":B12.image="cadeau":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 13 : B1.image="cadeau":B2.image="cadeau":B3.image="cadeau":B4.image="cadeau":B5.image="cadeau":B6.image="cadeau":B7.image="cadeau":B8.image="cadeau":B9.image="cadeau":B10.image="cadeau":B11.image="cadeau":B12.image="cadeau":B13.image="cadeau":B14.image="cadeauW":B15.image="cadeauW"
			case 14 : B1.image="cadeau":B2.image="cadeau":B3.image="cadeau":B4.image="cadeau":B5.image="cadeau":B6.image="cadeau":B7.image="cadeau":B8.image="cadeau":B9.image="cadeau":B10.image="cadeau":B11.image="cadeau":B12.image="cadeau":B13.image="cadeau":B14.image="cadeau":B15.image="cadeauW"
			case 15 : B1.image="cadeau":B2.image="cadeau":B3.image="cadeau":B4.image="cadeau":B5.image="cadeau":B6.image="cadeau":B7.image="cadeau":B8.image="cadeau":B9.image="cadeau":B10.image="cadeau":B11.image="cadeau":B12.image="cadeau":B13.image="cadeau":B14.image="cadeau":B15.image="cadeau"
			end Select
End Sub

sub forshotball1b
Tchglanes1a.enabled = false
forshotball1a
countr2 = 0
end sub

'****************************************************BALL 2*****************************************************

sub forshotball2
B1.image="cadeau4"
B2.image="cadeau3"
B3.image="cadeau4"
B4.image="cadeau3"
B5.image="cadeau4"
B6.image="cadeau3"
B7.image="cadeau4"
B8.image="cadeau3"
B9.image="cadeau4"
B10.image="cadeau3"
B11.image="cadeau4"
B12.image="cadeau3"
B13.image="cadeau4"
B14.image="cadeau3"
B15.image="cadeau4"
end sub

sub forshotball2a
B1.image="cadeau3"
B2.image="cadeau4"
B3.image="cadeau3"
B4.image="cadeau4"
B5.image="cadeau3"
B6.image="cadeau4"
B7.image="cadeau3"
B8.image="cadeau4"
B9.image="cadeau3"
B10.image="cadeau4"
B11.image="cadeau3"
B12.image="cadeau4"
B13.image="cadeau3"
B14.image="cadeau4"
B15.image="cadeau3"
end sub

Sub Tchglanes2_Timer
countr3 = countr3 + 1 : If Countr3 > 2 then Countr3 = 1 : end If 
select case countr3
			case 1 :forshotball2 
			case 2 :forshotball2a 
			end Select
End Sub

Sub Tchglanes2a_Timer
countr4 = countr4 + 1 : If Countr4 > 15 then forshotball2b 'Countr35 = 1 : end If 
select case countr4
			case 1 : B1.image="cadeau4":B2.image="cadeauW":B3.image="cadeauW":B4.image="cadeauW":B5.image="cadeauW":B6.image="cadeauW":B7.image="cadeauW":B8.image="cadeauW":B9.image="cadeauW":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 2 : B1.image="cadeau4":B2.image="cadeau4":B3.image="cadeauW":B4.image="cadeauW":B5.image="cadeauW":B6.image="cadeauW":B7.image="cadeauW":B8.image="cadeauW":B9.image="cadeauW":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 3 : B1.image="cadeau4":B2.image="cadeau4":B3.image="cadeau4":B4.image="cadeauW":B5.image="cadeauW":B6.image="cadeauW":B7.image="cadeauW":B8.image="cadeauW":B9.image="cadeauW":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 4 : B1.image="cadeau4":B2.image="cadeau4":B3.image="cadeau4":B4.image="cadeau4":B5.image="cadeauW":B6.image="cadeauW":B7.image="cadeauW":B8.image="cadeauW":B9.image="cadeauW":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 5 : B1.image="cadeau4":B2.image="cadeau4":B3.image="cadeau4":B4.image="cadeau4":B5.image="cadeau4":B6.image="cadeauW":B7.image="cadeauW":B8.image="cadeauW":B9.image="cadeauW":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 6 : B1.image="cadeau4":B2.image="cadeau4":B3.image="cadeau4":B4.image="cadeau4":B5.image="cadeau4":B6.image="cadeau4":B7.image="cadeauW":B8.image="cadeauW":B9.image="cadeauW":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 7 : B1.image="cadeau4":B2.image="cadeau4":B3.image="cadeau4":B4.image="cadeau4":B5.image="cadeau4":B6.image="cadeau4":B7.image="cadeau4":B8.image="cadeauW":B9.image="cadeauW":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 8 : B1.image="cadeau4":B2.image="cadeau4":B3.image="cadeau4":B4.image="cadeau4":B5.image="cadeau4":B6.image="cadeau4":B7.image="cadeau4":B8.image="cadeau4":B9.image="cadeauW":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 9 : B1.image="cadeau4":B2.image="cadeau4":B3.image="cadeau4":B4.image="cadeau4":B5.image="cadeau4":B6.image="cadeau4":B7.image="cadeau4":B8.image="cadeau4":B9.image="cadeau4":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 10 : B1.image="cadeau4":B2.image="cadeau4":B3.image="cadeau4":B4.image="cadeau4":B5.image="cadeau4":B6.image="cadeau4":B7.image="cadeau4":B8.image="cadeau4":B9.image="cadeau4":B10.image="cadeau4":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 11 : B1.image="cadeau4":B2.image="cadeau4":B3.image="cadeau4":B4.image="cadeau4":B5.image="cadeau4":B6.image="cadeau4":B7.image="cadeau4":B8.image="cadeau4":B9.image="cadeau4":B10.image="cadeau4":B11.image="cadeau4":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 12 : B1.image="cadeau4":B2.image="cadeau4":B3.image="cadeau4":B4.image="cadeau4":B5.image="cadeau4":B6.image="cadeau4":B7.image="cadeau4":B8.image="cadeau4":B9.image="cadeau4":B10.image="cadeau4":B11.image="cadeau4":B12.image="cadeau4":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 13 : B1.image="cadeau4":B2.image="cadeau4":B3.image="cadeau4":B4.image="cadeau4":B5.image="cadeau4":B6.image="cadeau4":B7.image="cadeau4":B8.image="cadeau4":B9.image="cadeau4":B10.image="cadeau4":B11.image="cadeau4":B12.image="cadeau4":B13.image="cadeau4":B14.image="cadeauW":B15.image="cadeauW"
			case 14 : B1.image="cadeau4":B2.image="cadeau4":B3.image="cadeau4":B4.image="cadeau4":B5.image="cadeau4":B6.image="cadeau4":B7.image="cadeau4":B8.image="cadeau4":B9.image="cadeau4":B10.image="cadeau4":B11.image="cadeau4":B12.image="cadeau4":B13.image="cadeau4":B14.image="cadeau4":B15.image="cadeauW"
			case 15 : B1.image="cadeau4":B2.image="cadeau4":B3.image="cadeau4":B4.image="cadeau4":B5.image="cadeau4":B6.image="cadeau4":B7.image="cadeau4":B8.image="cadeau4":B9.image="cadeau4":B10.image="cadeau4":B11.image="cadeau4":B12.image="cadeau4":B13.image="cadeau4":B14.image="cadeau4":B15.image="cadeau4"
			end Select
End Sub

sub forshotball2b
Tchglanes2a.enabled = false
forshotball2
countr4 = 0
end sub

'****************************************************BALL 3*****************************************************

sub forshotball3
B1.image="cadeau6"
B2.image="cadeau5"
B3.image="cadeau6"
B4.image="cadeau5"
B5.image="cadeau6"
B6.image="cadeau5"
B7.image="cadeau6"
B8.image="cadeau5"
B9.image="cadeau6"
B10.image="cadeau5"
B11.image="cadeau6"
B12.image="cadeau5"
B13.image="cadeau6"
B14.image="cadeau5"
B15.image="cadeau6"
end sub

sub forshotball3a
B1.image="cadeau5"
B2.image="cadeau6"
B3.image="cadeau5"
B4.image="cadeau6"
B5.image="cadeau5"
B6.image="cadeau6"
B7.image="cadeau5"
B8.image="cadeau6"
B9.image="cadeau5"
B10.image="cadeau6"
B11.image="cadeau5"
B12.image="cadeau6"
B13.image="cadeau5"
B14.image="cadeau6"
B15.image="cadeau5"
end sub

Sub Tchglanes3_Timer
countr5 = countr5 + 1 : If countr5 > 2 then countr5 = 1 : end If 
select case countr5
			case 1 :forshotball3
			case 2 :forshotball3a 
			end Select
End Sub

Sub Tchglanes3a_Timer
countr6 = countr6 + 1 : If countr6 > 15 then forshotball3b 'countr535 = 1 : end If 
select case countr6
			case 1 : B1.image="cadeau5a":B2.image="cadeauW":B3.image="cadeauW":B4.image="cadeauW":B5.image="cadeauW":B6.image="cadeauW":B7.image="cadeauW":B8.image="cadeauW":B9.image="cadeauW":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 2 : B1.image="cadeau5a":B2.image="cadeau5a":B3.image="cadeauW":B4.image="cadeauW":B5.image="cadeauW":B6.image="cadeauW":B7.image="cadeauW":B8.image="cadeauW":B9.image="cadeauW":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 3 : B1.image="cadeau5a":B2.image="cadeau5a":B3.image="cadeau5a":B4.image="cadeauW":B5.image="cadeauW":B6.image="cadeauW":B7.image="cadeauW":B8.image="cadeauW":B9.image="cadeauW":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 4 : B1.image="cadeau5a":B2.image="cadeau5a":B3.image="cadeau5a":B4.image="cadeau5a":B5.image="cadeauW":B6.image="cadeauW":B7.image="cadeauW":B8.image="cadeauW":B9.image="cadeauW":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 5 : B1.image="cadeau5a":B2.image="cadeau5a":B3.image="cadeau5a":B4.image="cadeau5a":B5.image="cadeau5a":B6.image="cadeauW":B7.image="cadeauW":B8.image="cadeauW":B9.image="cadeauW":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 6 : B1.image="cadeau5a":B2.image="cadeau5a":B3.image="cadeau5a":B4.image="cadeau5a":B5.image="cadeau5a":B6.image="cadeau5a":B7.image="cadeauW":B8.image="cadeauW":B9.image="cadeauW":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 7 : B1.image="cadeau5a":B2.image="cadeau5a":B3.image="cadeau5a":B4.image="cadeau5a":B5.image="cadeau5a":B6.image="cadeau5a":B7.image="cadeau5a":B8.image="cadeauW":B9.image="cadeauW":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 8 : B1.image="cadeau5a":B2.image="cadeau5a":B3.image="cadeau5a":B4.image="cadeau5a":B5.image="cadeau5a":B6.image="cadeau5a":B7.image="cadeau5a":B8.image="cadeau5a":B9.image="cadeauW":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 9 : B1.image="cadeau5a":B2.image="cadeau5a":B3.image="cadeau5a":B4.image="cadeau5a":B5.image="cadeau5a":B6.image="cadeau5a":B7.image="cadeau5a":B8.image="cadeau5a":B9.image="cadeau5a":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 10 : B1.image="cadeau5a":B2.image="cadeau5a":B3.image="cadeau5a":B4.image="cadeau5a":B5.image="cadeau5a":B6.image="cadeau5a":B7.image="cadeau5a":B8.image="cadeau5a":B9.image="cadeau5a":B10.image="cadeau5a":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 11 : B1.image="cadeau5a":B2.image="cadeau5a":B3.image="cadeau5a":B4.image="cadeau5a":B5.image="cadeau5a":B6.image="cadeau5a":B7.image="cadeau5a":B8.image="cadeau5a":B9.image="cadeau5a":B10.image="cadeau5a":B11.image="cadeau5a":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 12 : B1.image="cadeau5a":B2.image="cadeau5a":B3.image="cadeau5a":B4.image="cadeau5a":B5.image="cadeau5a":B6.image="cadeau5a":B7.image="cadeau5a":B8.image="cadeau5a":B9.image="cadeau5a":B10.image="cadeau5a":B11.image="cadeau5a":B12.image="cadeau5a":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 13 : B1.image="cadeau5a":B2.image="cadeau5a":B3.image="cadeau5a":B4.image="cadeau5a":B5.image="cadeau5a":B6.image="cadeau5a":B7.image="cadeau5a":B8.image="cadeau5a":B9.image="cadeau5a":B10.image="cadeau5a":B11.image="cadeau5a":B12.image="cadeau5a":B13.image="cadeau5a":B14.image="cadeauW":B15.image="cadeauW"
			case 14 : B1.image="cadeau5a":B2.image="cadeau5a":B3.image="cadeau5a":B4.image="cadeau5a":B5.image="cadeau5a":B6.image="cadeau5a":B7.image="cadeau5a":B8.image="cadeau5a":B9.image="cadeau5a":B10.image="cadeau5a":B11.image="cadeau5a":B12.image="cadeau5a":B13.image="cadeau5a":B14.image="cadeau5a":B15.image="cadeauW"
			case 15 : B1.image="cadeau5a":B2.image="cadeau5a":B3.image="cadeau5a":B4.image="cadeau5a":B5.image="cadeau5a":B6.image="cadeau5a":B7.image="cadeau5a":B8.image="cadeau5a":B9.image="cadeau5a":B10.image="cadeau5a":B11.image="cadeau5a":B12.image="cadeau5a":B13.image="cadeau5a":B14.image="cadeau5a":B15.image="cadeau5a"
			end Select
End Sub

sub forshotball3b
Tchglanes3a.enabled = false
forshotball3a
countr6 = 0
end sub

'****************************************************BALL 4*****************************************************

sub forshotball4
B1.image="cadeau8"
B2.image="cadeau7"
B3.image="cadeau8"
B4.image="cadeau7"
B5.image="cadeau8"
B6.image="cadeau7"
B7.image="cadeau8"
B8.image="cadeau7"
B9.image="cadeau8"
B10.image="cadeau7"
B11.image="cadeau8"
B12.image="cadeau7"
B13.image="cadeau8"
B14.image="cadeau7"
B15.image="cadeau8"
end sub

sub forshotball4a
B1.image="cadeau7"
B2.image="cadeau8"
B3.image="cadeau7"
B4.image="cadeau8"
B5.image="cadeau7"
B6.image="cadeau8"
B7.image="cadeau7"
B8.image="cadeau8"
B9.image="cadeau7"
B10.image="cadeau8"
B11.image="cadeau7"
B12.image="cadeau8"
B13.image="cadeau7"
B14.image="cadeau8"
B15.image="cadeau7"
end sub

Sub Tchglanes4_Timer
countr7 = countr7 + 1 : If countr7 > 2 then countr7 = 1 : end If 
select case countr7
			case 1 :forshotball4 
			case 2 :forshotball4a 
			end Select
End Sub

Sub Tchglanes4a_Timer
countr8 = countr8 + 1 : If countr8 > 15 then forshotball4b 'countr735 = 1 : end If 
select case countr8
			case 1 : B1.image="cadeau7":B2.image="cadeauW":B3.image="cadeauW":B4.image="cadeauW":B5.image="cadeauW":B6.image="cadeauW":B7.image="cadeauW":B8.image="cadeauW":B9.image="cadeauW":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 2 : B1.image="cadeau7":B2.image="cadeau7":B3.image="cadeauW":B4.image="cadeauW":B5.image="cadeauW":B6.image="cadeauW":B7.image="cadeauW":B8.image="cadeauW":B9.image="cadeauW":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 3 : B1.image="cadeau7":B2.image="cadeau7":B3.image="cadeau7":B4.image="cadeauW":B5.image="cadeauW":B6.image="cadeauW":B7.image="cadeauW":B8.image="cadeauW":B9.image="cadeauW":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 4 : B1.image="cadeau7":B2.image="cadeau7":B3.image="cadeau7":B4.image="cadeau7":B5.image="cadeauW":B6.image="cadeauW":B7.image="cadeauW":B8.image="cadeauW":B9.image="cadeauW":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 5 : B1.image="cadeau7":B2.image="cadeau7":B3.image="cadeau7":B4.image="cadeau7":B5.image="cadeau7":B6.image="cadeauW":B7.image="cadeauW":B8.image="cadeauW":B9.image="cadeauW":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 6 : B1.image="cadeau7":B2.image="cadeau7":B3.image="cadeau7":B4.image="cadeau7":B5.image="cadeau7":B6.image="cadeau7":B7.image="cadeauW":B8.image="cadeauW":B9.image="cadeauW":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 7 : B1.image="cadeau7":B2.image="cadeau7":B3.image="cadeau7":B4.image="cadeau7":B5.image="cadeau7":B6.image="cadeau7":B7.image="cadeau7":B8.image="cadeauW":B9.image="cadeauW":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 8 : B1.image="cadeau7":B2.image="cadeau7":B3.image="cadeau7":B4.image="cadeau7":B5.image="cadeau7":B6.image="cadeau7":B7.image="cadeau7":B8.image="cadeau7":B9.image="cadeauW":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 9 : B1.image="cadeau7":B2.image="cadeau7":B3.image="cadeau7":B4.image="cadeau7":B5.image="cadeau7":B6.image="cadeau7":B7.image="cadeau7":B8.image="cadeau7":B9.image="cadeau7":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 10 : B1.image="cadeau7":B2.image="cadeau7":B3.image="cadeau7":B4.image="cadeau7":B5.image="cadeau7":B6.image="cadeau7":B7.image="cadeau7":B8.image="cadeau7":B9.image="cadeau7":B10.image="cadeau7":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 11 : B1.image="cadeau7":B2.image="cadeau7":B3.image="cadeau7":B4.image="cadeau7":B5.image="cadeau7":B6.image="cadeau7":B7.image="cadeau7":B8.image="cadeau7":B9.image="cadeau7":B10.image="cadeau7":B11.image="cadeau7":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 12 : B1.image="cadeau7":B2.image="cadeau7":B3.image="cadeau7":B4.image="cadeau7":B5.image="cadeau7":B6.image="cadeau7":B7.image="cadeau7":B8.image="cadeau7":B9.image="cadeau7":B10.image="cadeau7":B11.image="cadeau7":B12.image="cadeau7":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 13 : B1.image="cadeau7":B2.image="cadeau7":B3.image="cadeau7":B4.image="cadeau7":B5.image="cadeau7":B6.image="cadeau7":B7.image="cadeau7":B8.image="cadeau7":B9.image="cadeau7":B10.image="cadeau7":B11.image="cadeau7":B12.image="cadeau7":B13.image="cadeau7":B14.image="cadeauW":B15.image="cadeauW"
			case 14 : B1.image="cadeau7":B2.image="cadeau7":B3.image="cadeau7":B4.image="cadeau7":B5.image="cadeau7":B6.image="cadeau7":B7.image="cadeau7":B8.image="cadeau7":B9.image="cadeau7":B10.image="cadeau7":B11.image="cadeau7":B12.image="cadeau7":B13.image="cadeau7":B14.image="cadeau7":B15.image="cadeauW"
			case 15 : B1.image="cadeau7":B2.image="cadeau7":B3.image="cadeau7":B4.image="cadeau7":B5.image="cadeau7":B6.image="cadeau7":B7.image="cadeau7":B8.image="cadeau7":B9.image="cadeau7":B10.image="cadeau7":B11.image="cadeau7":B12.image="cadeau7":B13.image="cadeau7":B14.image="cadeau7":B15.image="cadeau7"
			end Select
End Sub

sub forshotball4b
Tchglanes4a.enabled = false
forshotball4
countr8 = 0
end sub

'****************************************************BALL 5*****************************************************

sub forshotball5
B1.image="cadeau10"
B2.image="cadeau9"
B3.image="cadeau10"
B4.image="cadeau9"
B5.image="cadeau10"
B6.image="cadeau9"
B7.image="cadeau10"
B8.image="cadeau9"
B9.image="cadeau10"
B10.image="cadeau9"
B11.image="cadeau10"
B12.image="cadeau9"
B13.image="cadeau10"
B14.image="cadeau9"
B15.image="cadeau10"
end sub

sub forshotball5a
B1.image="cadeau9"
B2.image="cadeau10"
B3.image="cadeau9"
B4.image="cadeau10"
B5.image="cadeau9"
B6.image="cadeau10"
B7.image="cadeau9"
B8.image="cadeau10"
B9.image="cadeau9"
B10.image="cadeau10"
B11.image="cadeau9"
B12.image="cadeau10"
B13.image="cadeau9"
B14.image="cadeau10"
B15.image="cadeau9"
end sub

Sub Tchglanes5_Timer
countr9 = countr9 + 1 : If countr9 > 2 then countr9 = 1 : end If 
select case countr9
			case 1 :forshotball5 
			case 2 :forshotball5a 
			end Select
End Sub

Sub Tchglanes5a_Timer
countr10 = countr10 + 1 : If countr10 > 15 then forshotball5b 'countr935 = 1 : end If 
select case countr10
			case 1 : B1.image="cadeau10":B2.image="cadeauW":B3.image="cadeauW":B4.image="cadeauW":B5.image="cadeauW":B6.image="cadeauW":B7.image="cadeauW":B8.image="cadeauW":B9.image="cadeauW":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 2 : B1.image="cadeau10":B2.image="cadeau10":B3.image="cadeauW":B4.image="cadeauW":B5.image="cadeauW":B6.image="cadeauW":B7.image="cadeauW":B8.image="cadeauW":B9.image="cadeauW":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 3 : B1.image="cadeau10":B2.image="cadeau10":B3.image="cadeau10":B4.image="cadeauW":B5.image="cadeauW":B6.image="cadeauW":B7.image="cadeauW":B8.image="cadeauW":B9.image="cadeauW":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 4 : B1.image="cadeau10":B2.image="cadeau10":B3.image="cadeau10":B4.image="cadeau10":B5.image="cadeauW":B6.image="cadeauW":B7.image="cadeauW":B8.image="cadeauW":B9.image="cadeauW":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 5 : B1.image="cadeau10":B2.image="cadeau10":B3.image="cadeau10":B4.image="cadeau10":B5.image="cadeau10":B6.image="cadeauW":B7.image="cadeauW":B8.image="cadeauW":B9.image="cadeauW":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 6 : B1.image="cadeau10":B2.image="cadeau10":B3.image="cadeau10":B4.image="cadeau10":B5.image="cadeau10":B6.image="cadeau10":B7.image="cadeauW":B8.image="cadeauW":B9.image="cadeauW":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 7 : B1.image="cadeau10":B2.image="cadeau10":B3.image="cadeau10":B4.image="cadeau10":B5.image="cadeau10":B6.image="cadeau10":B7.image="cadeau10":B8.image="cadeauW":B9.image="cadeauW":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 8 : B1.image="cadeau10":B2.image="cadeau10":B3.image="cadeau10":B4.image="cadeau10":B5.image="cadeau10":B6.image="cadeau10":B7.image="cadeau10":B8.image="cadeau10":B9.image="cadeauW":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 9 : B1.image="cadeau10":B2.image="cadeau10":B3.image="cadeau10":B4.image="cadeau10":B5.image="cadeau10":B6.image="cadeau10":B7.image="cadeau10":B8.image="cadeau10":B9.image="cadeau10":B10.image="cadeauW":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 10 : B1.image="cadeau10":B2.image="cadeau10":B3.image="cadeau10":B4.image="cadeau10":B5.image="cadeau10":B6.image="cadeau10":B7.image="cadeau10":B8.image="cadeau10":B9.image="cadeau10":B10.image="cadeau10":B11.image="cadeauW":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 11 : B1.image="cadeau10":B2.image="cadeau10":B3.image="cadeau10":B4.image="cadeau10":B5.image="cadeau10":B6.image="cadeau10":B7.image="cadeau10":B8.image="cadeau10":B9.image="cadeau10":B10.image="cadeau10":B11.image="cadeau10":B12.image="cadeauW":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 12 : B1.image="cadeau10":B2.image="cadeau10":B3.image="cadeau10":B4.image="cadeau10":B5.image="cadeau10":B6.image="cadeau10":B7.image="cadeau10":B8.image="cadeau10":B9.image="cadeau10":B10.image="cadeau10":B11.image="cadeau10":B12.image="cadeau10":B13.image="cadeauW":B14.image="cadeauW":B15.image="cadeauW"
			case 13 : B1.image="cadeau10":B2.image="cadeau10":B3.image="cadeau10":B4.image="cadeau10":B5.image="cadeau10":B6.image="cadeau10":B7.image="cadeau10":B8.image="cadeau10":B9.image="cadeau10":B10.image="cadeau10":B11.image="cadeau10":B12.image="cadeau10":B13.image="cadeau10":B14.image="cadeauW":B15.image="cadeauW"
			case 14 : B1.image="cadeau10":B2.image="cadeau10":B3.image="cadeau10":B4.image="cadeau10":B5.image="cadeau10":B6.image="cadeau10":B7.image="cadeau10":B8.image="cadeau10":B9.image="cadeau10":B10.image="cadeau10":B11.image="cadeau10":B12.image="cadeau10":B13.image="cadeau10":B14.image="cadeau10":B15.image="cadeauW"
			case 15 : B1.image="cadeau10":B2.image="cadeau10":B3.image="cadeau10":B4.image="cadeau10":B5.image="cadeau10":B6.image="cadeau10":B7.image="cadeau10":B8.image="cadeau10":B9.image="cadeau10":B10.image="cadeau10":B11.image="cadeau10":B12.image="cadeau10":B13.image="cadeau10":B14.image="cadeau10":B15.image="cadeau10"
			end Select
End Sub

sub forshotball5b
Tchglanes5a.enabled = false
forshotball5a
countr10 = 0
end sub


'************************************************
'***************turning objects******************
'************************************************
Sub itemrotztimer_Timer
   Pizza001.Rotz = Pizza001.Rotz + 1
   if Pizza001.Rotz > 360 then
	   Pizza001.Rotz = 1
   end if
   Pslice001.Rotz = Pslice001.Rotz + 1
   if Pslice001.Rotz > 360 then
	   Pslice001.Rotz = 1
   end if
end sub


Sub itemrotytimer_Timer()
	Monitor001.RotY = Monitor001.RotY + 1
	if Monitor001.RotY > 360 then
		Monitor001.RotY = 1
	end if
	Microphone001.RotY = Microphone001.RotY + 1
	if Microphone001.RotY > 360 then
		Microphone001.RotY = 1
	end if
	voicerecorder001.RotY = voicerecorder001.RotY + 1
	if voicerecorder001.RotY > 360 then
		voicerecorder001.RotY = 1
	end if
	Guitar001.RotY = Guitar001.RotY + 1
	if Guitar001.RotY > 360 then
		Guitar001.RotY = 1
	end if
	Milkshake001.RotY = Milkshake001.RotY + 1
	if Milkshake001.RotY > 360 then
		Milkshake001.RotY = 1
	end if
	Present001.RotY = Present001.RotY + 1
	if Present001.RotY > 360 then
		Present001.RotY = 1
	end if
	Canz001.RotY = Canz001.RotY + 1
	if Canz001.RotY > 360 then
		Canz001.RotY = 1
	end if
end sub