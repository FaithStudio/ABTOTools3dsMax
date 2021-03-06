-- This script gives some small tools for UV mapping in 3ds max

-- Made by Dmitry Maslov @ http://maslov.co
-- Skype: blitz3dproger
-- Telegram: @ABTOMAT
-- GitHub: ABTOMAT

-- January 2018.

macroScript ABTOUV
category:"ABTO Tools"
icon:#("Max_Edit_Modifiers",13)
(
undo off (

	scriptVersion = "0.3"

	config =
	#(
		#("option", "")
	)
	
	terminateScript = false
	
	fn getSetting settingName = (
		for i = 1 to config.count do
		(
			settingNameInConf = config[i][1]
			if(settingName == settingNameInConf) then
			(
				return (config[i][2])
			)			
		)
		
		return undefined		
	)
	
	fn setSetting settingName settingVal =
	(
		for i = 1 to config.count do
		(
			settingNameInConf = config[i][1]
			if(settingName == settingNameInConf) then
			(
				config[i][2] = settingVal
				return true
			)			
		)
		
		-- No such setting found - write your own
		append config #(settingName, settingVal)
		
		return false
	)
	
	fn getTempPath = (return (getSetting("pathArtMesh")+"\ABTO Temp Files"))
	fn getArtMeshConfPath = (return (getSetting("pathArtMesh")+"\cmd.txt"))
	fn getArtMeshExePath = (return (getSetting("pathArtMesh")+"\artmesh_cmd.exe"))
	
	fn saveConfig =
	(
		configPath = (getdir #plugcfg)+"\\"+"ABTOTools.ini"
		file = fopen configPath "wb"
		
		WriteShort file config.count
		
		for i = 1 to config.count do
		(
			settingName = config[i][1]
			settingVal = config[i][2]
			
			WriteString file settingName
			WriteString file (settingVal	as string)		
		)
		
		fclose file
	)
	
	fn loadConfig =
	(
		configPath = (getdir #plugcfg)+"\\"+ "ABTOTools.ini"
				
		if (not doesFileExist(configPath)) then
		(
			saveConfig()
		)
		
		file = fopen configPath "rb"
		
		configCount = ReadShort(file)
		
		for i = 1 to configCount do
		(
			settingName = ReadString (file)
			settingVal = ReadString (file)
			
			setSetting settingName settingVal
		)		
		fclose file		
	)
	
	fn getUnwrapUVW =
	(
		unwrapuvw = undefined
		
		for obj in selection do
		(
			for modif in obj.modifiers do
			(
				if modif.name == "Unwrap UVW" then
				(
					unwrapuvw = modif
				)
			)
		)
		
		/*
		all_verts = #{1..unwrapuvw.numberVertices()}				
		unwrapuvw.selectVertices all_verts
		*/
		
		return unwrapuvw
	)
	
	
	fn findVertsToWeld unwrapuvw verts vertToCheck threshold mode = 
	(	
		-- Mode: 1 = Regular | 2 = Only U | 3 = Only V
	
		vertsToWeld = #()
		vertsToWeldIndices = #()
				
		vertToCheckPos = unwrapuvw.getVertexPosition currenttime vertToCheck
		vertToCheckPos.z = 0 -- we check only U and V
		
		case mode of
		(
			2: -- Only U
			(
				vertToCheckPos.y = 0
			)
			3: -- Only V
			(
				vertToCheckPos.x = 0
			)
		)
		
		for i = 1 to verts.count do
		(
			if verts[i] != vertToCheck then
			(
				vertPos = unwrapuvw.getVertexPosition currenttime verts[i]
				vertPos.z = 0 -- we check only U and V
				
				case mode of
				(
					2: -- Only U
					(
						vertPos.y = 0
					)
					3: -- Only V
					(
						vertPos.x = 0
					)
				)
				
				dist = distance vertPos vertToCheckPos
								
				if dist < threshold then
				(
					append vertsToWeld verts[i]
					append vertsToWeldIndices i
				)
				endif
			)
			else
			(
				-- Add this vertex to the list to be removed without checking coords
				append vertsToWeldIndices i
			)
			endif
		)
		
		-- Exclude the previously found vertices from the main vert array
		
		for i = vertsToWeldIndices.count to 1 by -1 do
		(
			deleteItem verts vertsToWeldIndices[i]
		)
		
		-- Now recursively find welding vertices for vertices we've found
		
		for i = vertsToWeld.count to 1 by -1 do
		(
			join vertsToWeld (findVertsToWeld unwrapuvw verts vertsToWeld[i] threshold mode)
		)
		
		-- At last add the initial vertex 		
		append vertsToWeld vertToCheck
		
		return vertsToWeld
	)
	
	fn weld unwrapuvw vertices mode =
	(
		uAverage = 0
		vAverage = 0
	
		for i=1 to vertices.count do
		(
			vertPos = unwrapuvw.getVertexPosition currenttime vertices[i]
		
			uAverage = uAverage + vertPos.x
			vAverage = vAverage + vertPos.y
		)
		
		uAverage = uAverage/vertices.count
		vAverage = vAverage/vertices.count
				
		for i=1 to vertices.count do
		(
			vertPos = unwrapuvw.getVertexPosition currenttime vertices[i]
			
			case mode of
			(
				1: -- Regular
				(
					vertPos.x = uAverage
					vertPos.y = vAverage
				)
				2: -- Only U
				(
					vertPos.x = uAverage
				)
				3: -- Only V
				(
					vertPos.y = vAverage
				)
			)
			
			unwrapuvw.SetVertexPosition currenttime vertices[i] vertPos
		)
		
	)

	
	loadConfig ()

		presetValues = #(
		-- Preset 1
		#(
			"0.01"
			

		),
		
		-- Preset 2
		#(
			"0.02"

		)
	)
	
	rollout ABTOTools ("ABTO Tools v"+scriptVersion) width:220 height:200
	(
		/*
		group "Start Processing"
		(
			
		)
		*/
		
		group "Weld UVs"
		(		
			radiobuttons welding_radio_threshold "Threshold" labels:#("0.25","0.1","0.05", "0.025", "0.01", "0.005", "0.0025", "0.001", "Custom") columns:3
			
			spinner welding_input_threshold "Custom Threshold" range:[0,2,(presetValues[1][1] as float)] scale:0.001
			
			
			
			radiobuttons welding_radio_mode labels:#("Regular", "Only U", "Only V")
			
			button btnGo "W E L D!" toolTip:"" width:130

		)
		
		hyperLink scriptpage "Script Homepage" color:(color 128 128 255) hoverColor:(color 200 200 255) visitedColor:(color 0 0 255) address:"https://github.com/ABTOMAT/ABTOTools3dsMax"	
		hyperLink authorpage "by Dmitry Maslov" color:(color 128 128 255) hoverColor:(color 200 200 255) visitedColor:(color 0 0 255) address:"http://maslov.co/"	 
		
		on welding_radio_threshold changed state do
		(
			
			setSetting "weldingThresholdRadio" welding_radio_threshold.state
		
			-- To-Do: Replace switch-case with reading values from array
		
			case welding_radio_threshold.state of
			(
				1:
				(
					setSetting "weldingThresholdVal"  0.25
				)
				2:
				(
					setSetting "weldingThresholdVal"  0.1
				)
				3:
				(
					setSetting "weldingThresholdVal"  0.05
				)
				4:
				(
					setSetting "weldingThresholdVal"  0.025
				)
				5:
				(
					setSetting "weldingThresholdVal"  0.01
				)
				6:
				(
					setSetting "weldingThresholdVal"  0.005
				)
				7:
				(
					setSetting "weldingThresholdVal"  0.0025
				)
				8:
				(
					setSetting "weldingThresholdVal"  0.001
				)
				9:
				(
					setSetting "weldingThresholdVal"  welding_input_threshold.value
					setSetting "weldingThresholdValCustom"  welding_input_threshold.value
				)
			)			
		
			if welding_radio_threshold.state == 9 then
				welding_input_threshold.enabled = true
			else
				welding_input_threshold.enabled = false
			endif
			
			
			saveConfig()
		)
		
		on welding_input_threshold changed value do
		(
			setSetting "weldingThresholdValCustom"  welding_input_threshold.value
			saveConfig()
		)
		
		on btnGo pressed do with undo label:"Weld vertices" on
		(
			if(selection.count != 0) then	
			(
				unwrapuvw = getUnwrapUVW()
				
				if (unwrapuvw != undefined) then
				(
					selectedVertices = unwrapuvw.getSelectedVertices() as array
					
					vertsToBeChecked = selectedVertices					
					weldingGroups = #()
					
					while vertsToBeChecked.count > 0 do
					(
						vertsToWeld = findVertsToWeld unwrapuvw vertsToBeChecked vertsToBeChecked[1] (getSetting "weldingThresholdVal") welding_radio_mode.state
						-- Append the groups found to array
						append weldingGroups vertsToWeld
					)
										
					-- Now weld the group of found vertices
					for i = 1 to weldingGroups.count do
					(
						weld unwrapuvw weldingGroups[i] welding_radio_mode.state
					)
					print (weldingGroups.count as string + " group(s) of vertices welded!")
				)
				else
					messagebox "The object should have Unwrap UVW Modifier!" title:"No Unwrap UVW!" beep:true
				endif
			)
			else			
				messagebox "Please select an object first!" title:"Nothing is selected" beep:true
			endif
		)
		
		
		on ABTOTools open do
		(
			-- To-Do: move this code to external function and enhance
			-- "Updatethersholdpresets or smth.
		
			setting_weldingThresholdValCustom  = getSetting "weldingThresholdValCustom"
			

			if setting_weldingThresholdValCustom == undefined then
			(
				setting_weldingThresholdValCustom = 0.01
			)
			setting_weldingThresholdValCustom = setting_weldingThresholdValCustom as float
			
			welding_input_threshold.value = setting_weldingThresholdValCustom
			
			-------------------
			
		
			setting_weldingThresholdRadio = getSetting "weldingThresholdRadio"
			

			
			if setting_weldingThresholdRadio == undefined then
			(
				setting_weldingThresholdRadio = 1
			)
			
			setting_weldingThresholdRadio = setting_weldingThresholdRadio as integer
			
			welding_radio_threshold.state = setting_weldingThresholdRadio
			
			case welding_radio_threshold.state of
			(
				1:
				(
					setSetting "weldingThresholdVal"  0.25
				)
				2:
				(
					setSetting "weldingThresholdVal"  0.1
				)
				3:
				(
					setSetting "weldingThresholdVal"  0.05
				)
				4:
				(
					setSetting "weldingThresholdVal"  0.025
				)
				5:
				(
					setSetting "weldingThresholdVal"  0.01
				)
				6:
				(
					setSetting "weldingThresholdVal"  0.005
				)
				7:
				(
					setSetting "weldingThresholdVal"  0.0025
				)
				8:
				(
					setSetting "weldingThresholdVal"  0.001
				)
				9:
				(
					setSetting "weldingThresholdVal"  welding_input_threshold.value
				)
			)			
		
			if welding_radio_threshold.state == 9 then
				welding_input_threshold.enabled = true
			else
				welding_input_threshold.enabled = false
			endif
			
		)
	)
	
	
	if(not terminateScript) then
	(
		CreateDialog ABTOTools height:200
	)
)
)