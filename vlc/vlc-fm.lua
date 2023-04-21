--[[
Program: File Management
Purpose: Delete, copy or move the current playing file

Author: Copyright 2019 Joeri Verscheure

License:

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

Manual:


DESCRIPTION:
Use FileManagement to delete, copy or move the current playing file.
For delete, no confirmation is asked and the Recycle Bin is not used.
This extension is tested on Windows 10 Home 1903 with VLC 3.0.8.
The author is not responsible for damage caused by this extension.


CONFIGURATION:
Configure the actions in this 'actions' variable. You can put as many buttons as you want (or no buttons at all). An example is provided.
]]

actions = {
{ column="1", actiontype="delete", button="Delete permanently", folder="", duplicate="", copystyle="" },
{ column="1", actiontype="move", button="Move to phone", folder="drive:/music/phone", duplicate="overwrite", copystyle="windowsrealmove" },
-- { column="1", actiontype="move", button="Delete", folder="drive:/Wastebasket", duplicate="both", copystyle="windowsrealmove" },
-- { column="1", actiontype="move", button="Move to testmove", folder="drive:/Data/media/test move", duplicate="both", copystyle="windowsrealmove" },
-- { column="2", actiontype="copy", button="Copy to testcopy", folder="drive:/Data/media/test copy", duplicate="both", copystyle="windowsrealmove" },
-- { column="2", actiontype="copy", button="Copy to C testcopy", folder="C:/Data/media/test copy", duplicate="both", copystyle="windowsrealmove" },
-- { column="2", actiontype="copy_next", button="Copy to testcopynext", folder="drive:/Data/media/test copynext", duplicate="both", copystyle="windowsrealmove" },
-- { column="2", actiontype="copy_next_remove", button="Copy to testcopynextremove", folder="drive:/Data/media/test copynextremove", duplicate="both", copystyle="windowsrealmove" },
}

--[[
'column' is the column where the button is put.

'actiontype' has 5 possibilities:
* delete: Delete the current playing file and remove it from the playlist. No confirmation is asked and the Recyle Bin is not used.
* move: Move the current playing file to another directory and remove it from the playlist.
* copy: Copy the current playing file to another directory.
* copy_next: Same as copy, but also moves to the next item in the playlist.
* copy_next_remove: Same as copy_next, but also removes the copied item from the playlist.

'button' is the text to display on the button.

'folder' is the folder to move or copy the file to (not used for actiontype 'delete', just put ""). Only absolute paths are supported. If the path begins with 'drive:', 'drive' will be replaced with the drive letter of the drive where the moved or copied file is located.

'duplicate' has 3 possibilities defining what should be done when the destination file already exists (not used for actiontype 'delete', just put ""):
* error: Move or copy is not done. An error is shown.
* overwrite: File is overwritten.
* both: Both files are kept in the destination folder. A number is added to the filename, e.g. (2).

'copystyle' has 3 possibilities defining how the file should be moved or copied (not used for actiontype 'delete', just put ""):
* windowsrealmove: Recommended for Windows. Supports real move (instead of copy + delete original), but is a bit tricky.
* windowssimple: Recommended for Windows if windowsrealmove doesn't work or real move is not needed.
* vlclua: Recommended for non-Windows OS or if you don't like the command prompt open and can live with the other downsides.

Full comparison csv for 'copystyle' (when 'yes' or 'supported', this is a pro, else a contra):

;vlclua;windowssimple;windowsrealmove
Copy method;vlc-lua-copy;xcopy;xcopy
Move method;vlc-lua-copy+delete;xcopy+delete;move+rename
Copy or move taking 10 seconds or more;vlc crash (+ possible incomplete move or copy);supported;supported
Universal OS support;yes (but only tested on Windows);Windows only;Windows only (*)
No command prompt visible during action;yes;no;no
Copy created timestamp preserved;no;no;no
Copy modified timestamp preserved;no;yes;yes
Move created timestamp preserved;no;no;yes
Move modified timestamp preserved;no;yes;yes
Copy readonly file;supported;supported;supported
Move readonly file;error upon delete original (copy done);error upon delete original (copy done);supported
Readonly preserved;no;yes;yes
Move file on same disk is a real move (is faster than copy+delete for large files);no;no;yes
(*) A move in this way is quite tricky because of possible special characters in the filename. It should work because it tries to use the short 8.3 names. But the solution may break with other Windows versions than the tested one. Also it is possible to disable short 8.3 names in Windows, which would break this solution (although this is by default not disabled).;;;


REMARKS:
* Delete of a readonly file is not possible.
* Overwrite of a readonly file is not possible.
* An action on a file with a very long path (>250 characters short or long path) can/will cause errors and unexpected results.
* Only one action can be executed at the same time. If an action is pending, clicking the buttons for another action will do nothing.
* When using a copystyle other than 'vlclua' and a copy or move takes more than about 5 seconds, the check for the action result is not done automatically. A button appears to check for the result. The pending action needs to be resolved first with this button before another action can be started.
* If an item is removed from the playlist, this doesn't mean the playlist is saved. You have to do this yourself if needed.
* Before an action is done (except for actiontype copy), VLC will first move to the next item with another path in the playlist (which is at least in Windows necessary to do a delete). It is assumed an item with another path is another file. It is assumed the action on the item will be completed before the item would be replayed (else an error 'Permission denied' will be shown).
* Moving to the next item ensures the file is unlocked in VLC. But of course this doesn't mean errors are impossible. The file could still be locked by something else. Or the file could be readonly. Appropriate errors are shown in such cases.
* Sometimes after moving to the next item, VLC stops instead of playing the next item, although there is no error. This seems an issue in VLC itself.


INSTALLATION:
Put the .lua file in the VLC subdir /lua/extensions, by default:
* Windows (all users): %ProgramFiles%\VideoLAN\VLC\lua\extensions\
* Windows (current user): %APPDATA%\VLC\lua\extensions\
* Linux (all users): /usr/share/vlc/lua/extensions/
* Linux (current user): ~/.local/share/vlc/lua/extensions/
* Mac OS X (all users): /Applications/VLC.app/Contents/MacOS/share/lua/extensions/
(create directories if they don't exist)
Restart VLC.


USAGE:
You use the extension by going to the "View" menu and selecting it there ("File Management").
]]


--[[ Extension description ]]

function descriptor()
	return {
		title = "FileManagement",
		version = "1.0.0",
		author = "Joeri Verscheure",
		shortdesc = "File Management",
		description = "<h1>FileManagement</h1>"
		.. "Use FileManagement to delete, copy or move the current playing file."
		.. "<br>For delete, no confirmation is asked and the Recycle Bin is not used."
		.. "<br>This extension is tested on Windows 10 Home 1903 with VLC 3.0.8."
		.. "<br>The author is not responsible for damage caused by this extension.",
		url = "",
		capabilities = {"playing-listener", "meta-listener", "input-listener"}
	}
end

--[[ Hooks ]]

-- Activation hook
function activate()
	vlc.msg.dbg("[FileManagement] activate")
	action_item = nil
	action_type = nil
	action_folder = nil
	action_duplicate = nil
	action_copystyle = nil
	action_copymoveoutput = nil
	action_fileto = nil
	action_waitingfornext = false
	action_waitingforcopymove = false
	action_continuecheckbusy = false
	action_recheckwaiting = false
	action_goto = nil
	columns = 1
	local column
	for i, v in pairs(actions) do
		if validate_action(v) then
			column = tonumber(v.column) or 1
			if column > columns then
				columns = column
			end
		end
	end
	d = vlc.dialog("File Management")
	d_playing = d:add_label("", 1, 1, columns, 1)
	d_name = d:add_label("", 1, 2, columns, 1)
	d_path = d:add_label("", 1, 3, columns, 1)
	d:add_label("", 1, 4, columns, 1)
	local row1 = 4
	row2 = row1
	local rows = {}
	for i, v in pairs(actions) do
		if validate_action(v) then
			column = tonumber(v.column) or 1
			rows[column] = (rows[column] or row1) + 1
			d:add_button(v.button, function() action_demand(v.actiontype, string.match(v.folder,"^(.-)[\\/]?$"), v.duplicate, v.copystyle) end, column, rows[column], 1, 1)
			if rows[column] > row2 then
				row2 = rows[column]
			end
		end
	end
	if row2 > row1 then
		d:add_label("", 1, row2 + 1, columns, 1)
		d_result1 = d:add_label("", 1, row2 + 2, columns, 1)
		d_result2 = d:add_label("", 1, row2 + 3, columns, 1)
		d_result3 = d:add_label("", 1, row2 + 4, columns, 1)
		d_recheck = nil
		d:add_label("", 1, row2 + 5, columns, 1)
		d:add_label("", 1, row2 + 6, columns, 1)
	end
	event_handling("activate")
end

-- Deactivation hook
function deactivate()
	vlc.msg.dbg("[FileManagement] deactivate")
	vlc.deactivate()
end

function close()
	deactivate()
end

function validate_action(v)
	return (v.actiontype == "delete" or (get_action_description(v.actiontype) ~= "Unknown" and v.folder ~= nil and v.folder ~= "" and (v.duplicate == "error" or v.duplicate == "overwrite" or v.duplicate == "both") and (v.copystyle == "windowssimple" or v.copystyle == "vlclua" or v.copystyle == "windowsrealmove"))) and v.button ~= nil
end

function get_action_description(actiontype)
	if actiontype == "delete" then return "Delete"
	elseif actiontype == "move" then return "Move"
	elseif actiontype == "copy" or actiontype == "copy_next" or actiontype == "copy_next_remove" then return "Copy"
	else return "Unknown"
	end
end

function set_text(widget, text, indentandbreak)
	local outputtext = text
	if indentandbreak then
		outputtext = "> "
		repeat
			outputtext = outputtext .. string.sub(text,1,120)
			if string.len(text) > 120 then
				outputtext = outputtext .. "<br>"
				text = string.sub(text,121)
			else
				text = nil
			end
		until not text
	end
	widget:set_text(outputtext)
end

function action_demand(actiontype, folder, duplicate, copystyle)
	starttime = os.time()
	local current_fix = current
	if action_item ~= nil then
		vlc.msg.dbg("[FileManagement] Action demand click is neglected. An action is already demanded.")
		return
	end
	set_text(d_result1,"")
	set_text(d_result2,"")
	set_text(d_result3,"")
	if playlist_is_empty() then
		set_text(d_result1,"<b style=\"color:red;\">Playlist is empty</b>")
	elseif current_fix.uri == "" then
		set_text(d_result1,"<b style=\"color:red;\">Nothing is playing</b>")
	elseif current_fix.filepath == "" then
		set_text(d_result1,"<b style=\"color:red;\">Something that is not a file is playing</b>")
		set_text(d_result2,"Uri: " .. current_fix.uri,"indentandbreak")
	elseif current_fix.changing then
		set_text(d_result1,"<b style=\"color:red;\">The current playing file is changing</b>")
	else
		if string.find(folder, "drive:", 1, true) == 1 then
			if string.find(current_fix.filepath, ":") == 2 then
				folder = string.sub(current_fix.filepath, 1, 1) .. string.sub(folder, 6)
			else
				set_text(d_result1,"<b style=\"color:red;\">The destination folder could not be determined</b>")
				return
			end
		end
		vlc.msg.dbg("[FileManagement] Action demanded @type " .. actiontype .. " @folder " .. folder .. " @duplicate " .. duplicate .. " @copystyle " .. copystyle .. " @path " .. current_fix.filepath)
		set_text(d_result1,"<b>" .. get_action_description(actiontype) .. " pending...</b>")
		set_text(d_result2,(actiontype == "delete" and "Filepath" or "From") .. ": " .. current_fix.filepath,"indentandbreak")
		if actiontype ~= "delete" then
			set_text(d_result3,"To folder: " .. folder,"indentandbreak")
		end
		d:update()
		if actiontype ~= "delete" then
			local retval, err = mkdirtree(folder)
			if not retval then
				set_text(d_result1,"<b style=\"color:red;\">" .. get_action_description(actiontype) .. " failed</b> - " .. (err or ""))
				return
			end
		end
		action_type = actiontype
		action_folder = folder
		action_duplicate = duplicate
		action_copystyle = copystyle
		action_copymoveoutput = nil
		aciton_fileto = nil
		action_item = current_fix
		action_waitingfornext = actiontype ~= "copy"
		action_waitingforcopymove = actiontype ~= "delete"
		action_continuecheckbusy = false
		action_recheckwaiting = false
		action_goto = nil
		if action_waitingfornext then
			action_goto = playnext(current_fix)
		end
		continuecheck()
	end
end

function playlist_is_empty()
	for _ in pairs(vlc.playlist.get("playlist",false).children) do
		return false
	end
	return true
end

function playnext(current_fix) -- play the next item in the playlist / don't use vlc.playlist.next() or vlc.playlist.skip(1) since these can actually replay the same file, even if only once in the playlist / my method should work and should also work for duplicate filepaths, but remark it will not return the next item random if shuffle mode is on / only problem I found so far is that from time to time the playlist is stopped althought the playlist still has more than one item
	local nextone = false
	vlc.msg.dbg("[FileManagement] playnext search - Current_fix @playlistid " .. current_fix.playlistid .. " @path " .. current_fix.filepath)
	for i, v in pairs(vlc.playlist.get("playlist",false).children) do
		if v.id == current_fix.playlistid then
			vlc.msg.dbg("[FileManagement] playnext search - Current_fix found")
			nextone = true
		elseif nextone and v.path ~= current_fix.uri then
			vlc.msg.dbg("[FileManagement] playnext found - New @playlistid " .. v.id .. " @path " .. v.path)
			vlc.playlist.goto(v.id)
			return v.id
		end
	end
	if nextone then
		for i, v in pairs(vlc.playlist.get("playlist",false).children) do
			if v.path ~= current_fix.uri then
				vlc.msg.dbg("[FileManagement] playnext found - New @playlistid " .. v.id .. " @path " .. v.path)
				vlc.playlist.goto(v.id)
				return v.id
			end
		end
	end
	vlc.msg.dbg("[FileManagement] playnext not found - Playlist is stopped")
	vlc.playlist.stop()
	return nil
end

function mkdirtree(folder)
	local retval, err
	local errortext
	local index = 0
	repeat
		index = string.find(folder, "[\\/]", index + 1)
		if index == nil or string.sub(folder, index - 1, index - 1):find("[:\\/]") == nil then
			retval, err = vlc.io.mkdir(index ~= nil and string.sub(folder, 1,index - 1) or folder, "0777")
			if retval ~= 0 and err ~= vlc.errno.EEXIST then
				errortext = get_errno_description(err)
				vlc.msg.dbg("[FileManagement] vlc.io.mkdir error: " .. errortext)
				return false, "Vlc.io.mkdir error: " .. errortext
			end
		end
	until index == nil
	return true
end

function continuecheck()
	action_continuecheckbusy = true
	local retval, err = continuecheck_core()
	if not action_waitingfornext and not action_waitingforcopymove then
		if not retval then
			set_text(d_result1,"<b style=\"color:red;\">" .. get_action_description(action_type) .. " failed</b> - " .. (err or ""))
		else
			set_text(d_result1,"<b style=\"color:darkgreen;\">" .. get_action_description(action_type) .. " successful</b>")
		end
		action_type = nil
		action_folder = nil
		action_duplicate = nil
		action_copystyle = nil
		action_copymoveoutput = nil
		action_fileto = nil
		action_item = nil
	end
	action_continuecheckbusy = false
end

function continuecheck_core()
	if action_waitingfornext then
		return true
	end
	if not action_waitingforcopymove then
		if action_type == "delete" then
			retval, err = action_execution_after_copymove()
			return retval, err		
		end
		return true
	end
	local retval, err
	local realaction = action_copystyle ~= "windowsrealmove" and "copy" or (action_type == "move" and "move" or "copy")
	if action_copymoveoutput == nil then
		if action_copystyle ~= "vlclua" then
			retval, err = execute_windows(realaction,action_item.filepath,action_folder,action_duplicate)
			if retval then
				action_copymoveoutput = retval
				action_fileto = err
			end
		else
			action_waitingforcopymove = false
			retval, err = copy(action_item.filepath,action_folder,action_duplicate)
			if retval then
				retval, err = action_execution_after_copymove()
				return retval, err
			end
		end
		if not retval then
			action_waitingforcopymove = false
			vlc.msg.dbg("[FileManagement] " .. realaction .. " error: " .. (err or ""))
			return false, "File " .. realaction .. " error: " .. (err or "")
		end
	end
	if action_copymoveoutput ~= nil then
		if file_exists(action_copymoveoutput) then
			action_waitingforcopymove = false
			action_recheckwaiting = false
			if d_recheck then
				d:del_widget(d_recheck)
				d_recheck = nil
			end
			local t0 = os.clock()
			local t1
			local rawread
			local retexe = ""
			while retexe == "" do
				t1 = os.clock()
				ff, err = vlc.io.open(action_copymoveoutput, "r")
				if not ff then
					execute_windows_end()
					return false, err
				end
				rawread = ff:read()
				ff:close()
				if rawread then
					retexe = rawread:match("^%s*(.-)%s*$")
				else
					retexe = ""
				end
				if t1 - t0 < 0 then t0 = os.clock() end
				if t1 - t0 > 1 then break end
			end
			if retexe ~= "0" then
				return false, "Error during " .. realaction
			end
			if not file_exists(action_fileto) then
				return false, "Error after " .. realaction .. " - file is not found in new location"
			end
			retval, err = action_execution_after_copymove()
			return retval, err
		else
			if not action_recheckwaiting then
				action_recheckwaiting = true
				set_text(d_result1,"<b>" .. get_action_description(action_type) .. " still pending.</b> Press the 'Recheck' button to get the action result.")
				if not d_recheck then
					d_recheck = d:add_button("Recheck", function() if action_item ~= nil and not action_continuecheckbusy then continuecheck() end end, 1, row2 + 5, columns, 1)
				end
				d:update()
			end
		end
	end
end

function action_execution_after_copymove()
	local retval, err
	local errortext
	if action_type == "delete" or (action_type == "move" and action_copystyle ~= "windowsrealmove") then
		retval, err = vlc.io.unlink(action_item.filepath) -- delete the file with this filepath from disk
		if retval ~= 0 then
			errortext = get_errno_description(err)
			vlc.msg.dbg("[FileManagement] vlc.io.unlink error: " .. errortext)
			return false, "Vlc.io.unlink error: " .. errortext
		end
	end
	if action_type ~= "copy" and action_type ~= "copy_next" then
		for i, v in pairs(vlc.playlist.get("playlist",false).children) do
			if v.path == action_item.uri then
				vlc.playlist.delete(v.id)
			end
		end
	end
	return true
end

function copy(from, to, duplicate)
	if unexpected_condition then
		return false, "Unexpected error"
	end
	local fileto = string.gsub(to,"\\","/") .. "/" .. (string.gsub(from,"\\","/"):match("^.+/(.+)$"))
	if file_exists(fileto) then
		if duplicate == "error" then
			return false, "Destination file already exists"
		elseif duplicate == "both" then
			fileto = get_non_duplicate_path(fileto)
		end
	end
	local ff, err = vlc.io.open(from, "rb")
	if not ff then
		return false, err
	end
	local ft, err = vlc.io.open(fileto, "wb")
	if not ft then
		ff:close()
		return false, err
	end
	if unexpected_condition then
		return false, "Error during copy"
	end
	local sz = 2^16
	local s
	repeat
		s = ff:read(sz)
	until not (s and ft:write(s))
	ff:close()
	ft:close()
	return true
end

function execute_windows(action, from, to, duplicate)
	local tempbat, temptxt, intermediatefolder, batchend
	function writebatch(self, command)
		-- Upon testing, just using build-in mechanismes to convert to a path with short names seemed to not provide reliable results. This solution seems reliable.
		self:write("@echo off\r\nCHCP 65001\r\nsetlocal enabledelayedexpansion\r\n" .. command .. "echo %errorlevel% > \"" .. temptxt .. "\"\r\nexit\r\n:getshortname\r\nset \"dirpath=\"\r\n:pathloop\r\nfor /f \"tokens=1* delims=/\" %%a in (\"!pathpart!\") do set \"pathpart=%%b\" & set \"partadd=%%a\" & (if \"!dirpath!\" neq \"\" for /f \"tokens=*\" %%i in ('dir !dirpath! /x') do set \"line=%%i\" & (if \"!line:~49!\" equ \"%%a\" (set \"shortpath=!line:~36,12!\" & (if \"!shortpath!\" neq \"            \" (if \"!shortpath:~-4!\" neq \"    \" (set \"partadd=!shortpath!\") else (set \"partadd=!shortpath:~0,-4!\")))))) & set \"dirpath=!dirpath!!partadd!\\\"\r\nif \"!pathpart!\" neq \"\" goto pathloop\r\ngoto :eof\r\n")
	end
	function writesimplebatch(self, command)
		self:write("@echo off\r\nCHCP 65001\r\n" .. command .. "echo %errorlevel% > \"" .. temptxt .. "\"\r\nexit\r\n")
	end
	if unexpected_condition then
		return false, "Unexpected error"
	end
	local retval, ft, ff, err
	local counter
	local specifyfile = false
	local fileto = string.gsub(to,"\\","/") .. "/" .. (string.gsub(from,"\\","/"):match("^.+/(.+)$"))
	local newpartone
	local newparttwo
	local intermediatefolder
	local questionedfilename
	local retexe
	local intermediatefile
	local intermediatefilerenamed
	if file_exists(fileto) then
		if duplicate == "error" then
			return false, "Destination file already exists"
		elseif duplicate == "both" then
			specifyfile = true
			fileto, newpartone, newparttwo = get_non_duplicate_path(fileto)
			if action == "copy" then
				-- Commented old solution. Not needed anymore because xcopy is used instead of copy. For copy this was needed to generate the short name for the new file and use the copy command with fileto instead of the folder. This solution however doesn't work for move command, so a more complicated solution is implemented for the move case.
				--ft, err = vlc.io.open(fileto, "w")
				--if not ft then
				--	return false, err
				--end
				--ft:close()
			else
				newpartone = string.gsub(newpartone,"\\","/"):match("^.+/(.+)$")
				newpartone = string.gsub(newpartone,"[^%.]","?")
				counter = 0
				retval = 1
				while retval ~= 0 do
					counter = counter + 1
					intermediatefolder = string.gsub(to,"\\","/") .. "/duplicate" .. counter
					retval, err = vlc.io.mkdir(intermediatefolder, "0777")
					if retval ~= 0 and err ~= vlc.errno.EEXIST then
						return false, "Unexpected error"
					end
				end
				intermediatefile = intermediatefolder .. "/" .. (string.gsub(from,"\\","/"):match("^.+/(.+)$"))
				intermediatefilerenamed = intermediatefolder .. "/" .. (string.gsub(fileto,"\\","/"):match("^.+/(.+)$"))
			end
		end
	end
	tempbat, temptxt = get_temp()
	if not tempbat then
		return false, "Unexpected error"
	end
	ft, err = vlc.io.open(tempbat, "w")
	if not ft then
		return false, err
	end
	if action == "copy" then
		-- Contrary to copy and move commands, xcopy command can actually accept special characters.
		writebatch(ft, batch_add_long_path(from,"from") .. batch_add_long_path(specifyfile and fileto or to,"to") .. "echo f | xcopy \"!from!\" \"!to!\" /k" .. (duplicate ~= "error" and " /y" or "") .. "\r\n")
	elseif action == "move" and not specifyfile then
		writebatch(ft, batch_add_short_path(from,"from") .. batch_add_short_path(specifyfile and fileto or to,"to") .. action .. (duplicate ~= "error" and " /y" or "") .. " !from! !to!\r\n")
	else
		writebatch(ft, batch_add_short_path(from,"from") .. batch_add_short_path(to,"to") .. batch_add_short_path(intermediatefolder,"intermediatefolder") .. "move !from! !intermediatefolder!\r\n" .. batch_add_short_path(intermediatefile,"intermediatefile") .. "rename !intermediatefile! \"" .. newpartone .. newparttwo .. "\"\r\n" .. batch_add_short_path(intermediatefilerenamed,"intermediatefilerenamed") .. "move !intermediatefilerenamed! !to!\r\nrmdir !intermediatefolder!\r\n")
	end
	ft:close()
	osexecute("start /b \"movecopyexecution\" \"" .. tempbat .. "\"")
	while not file_exists(temptxt) and os.difftime(os.time(),starttime) < 6 do end
	return temptxt, fileto
end

function osexecute(command)
	os.execute(command)
end

function get_non_duplicate_path(path)
	if not file_exists(path) then
		return path
	end
	local extension = string.match(path,"^.+(%..*)$")
	local withoutextension = path:sub(1,path:len()-extension:len())
	local newfiletostart = withoutextension
	local space = " "
	local currentnumber = 2
	local suffixafternumber = ""
	local suffix = string.match(withoutextension,"^.+(%(%d*%) *)$")
	local numberstartstr
	if suffix ~= nil then
		numberstartstr = string.match(suffix,"^%((%d*)%) *$")
		if numberstartstr == "" then
			currentnumber = 0
		else
			currentnumber = tonumber(numberstartstr) + 1
		end
		suffixafternumber = string.match(suffix,"^%(%d*%)( *)$")
		newfiletostart = path:sub(1,path:len()-suffix:len())
		space = ""
	end
	local candidate = newfiletostart .. space .. "(" .. currentnumber .. ")" .. suffixafternumber .. extension
	while file_exists(candidate) do
		currentnumber = currentnumber + 1
		candidate = newfiletostart .. space .. "(" .. currentnumber .. ")" .. suffixafternumber .. extension
	end
	return candidate, newfiletostart, space .. "(" .. currentnumber .. ")" .. suffixafternumber .. extension
end

function get_temp()
	local temp,temp2 = get_temp_core("TEMP")
	if temp then return temp,temp2 end
	temp,temp2 = get_temp_core("TMP")
	if temp then return temp,temp2 end
	temp,temp2 = get_temp_core("USERPROFILE")
	return temp,temp2
end

function get_temp_core(folder)
	local temp = string.gsub(os.getenv(folder),"\\","/") .. "/eovdjrdhk.bat"
	local ft, err = vlc.io.open(temp, "w")
	if not ft then
		return false,false
	end
	ft:close()
	local temp2 = string.gsub(os.getenv(folder),"\\","/") .. "/eovdjrdhk.txt"
	retval, err = vlc.io.unlink(temp2)
	if retval ~= 0 and err ~= vlc.errno.ENOENT then
		errortext = get_errno_description(err)
		vlc.msg.dbg("[FileManagement] vlc.io.unlink error: " .. errortext)
		return false, "Vlc.io.unlink error: " .. errortext
	end
	return temp,temp2
end

function batch_add_long_path(path, variable)
	return "set \"" .. variable .. "=" .. string.gsub(path,"/","\\"):gsub("%%","%%%%"):gsub("!","%^!") .. "\"\r\n"
end

function batch_add_short_path(path, variable)
	return "set \"pathpart=" .. string.gsub(path,"\\","/"):gsub("%%","%%%%"):gsub("!","%^!") .. "\"\r\ncall :getshortname\r\nset \"" .. variable .. "=!dirpath:~0,-1!\"\r\n"
end

function file_exists(path)
	local ff, err = vlc.io.open(path, "rb")
	if not ff then
		return false
	end
	ff:close()
	return true
end

function get_errno_description(errno)
	if errno == vlc.errno.ENOENT then return "No such file or directory"
	elseif errno == vlc.errno.EEXIST then return "File exists"
	elseif errno == vlc.errno.EACCES then return "Permission denied"
	elseif errno == vlc.errno.EINVAL then return "Invalid argument"
	else return errno
	end
end

--[[
	uri			"" = Nothing is playing
	name
	filepath	"" = Something that is not a file is playing
	changing	true = The current playing file is changing
	playlistid	may not be defined if changing is true, else always defined
--]]
Item = { uri = "", name = "", filepath = "", changing = true, plalistid = nil }

function Item:new(o)
	vlc.msg.dbg("[FileManagement] Item:new start")
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	o.changing = false
	local item = vlc.input.item() -- get the current playing file
	local playlist_item
	if item then
		o.playlistid = vlc.playlist.current()
		o.uri = item:uri()
		o.name = item:name()
		if not o.playlistid then
			vlc.msg.dbg("[FileManagement] Item:new - Playing item is found, but playlist current is not found")
			o.changing = true
		else
			playlist_item = vlc.playlist.get(o.playlistid,false)
			if not playlist_item then
				vlc.msg.dbg("[FileManagement] Item:new - Playlist current id is not found in the playlist")
				o.changing = true
			elseif o.uri ~= playlist_item.path then
				vlc.msg.dbg("[FileManagement] Item:new - Playlist current path doesn't match current playing item path")
				o.changing = true
			end
		end
		if string.find(o.uri, "file:///", 1, true) ~= 1 then
			o.filepath = ""
		else
			o.filepath = string.sub(vlc.strings.decode_uri(o.uri), 9)
		end
	else
		o.uri = ""
		o.name = ""
		o.filepath = ""
	end
	vlc.msg.dbg("[FileManagement] Item:new end")
	return o
end

function Item:display()
	vlc.msg.dbg("[FileManagement] Item:display start")
	if self.uri == "" then
		set_text(d_playing,"<b style=\"color:red;\">Nothing is playing</b>")
		set_text(d_name,"")
		set_text(d_path,"")
	elseif self.filepath == "" then
		set_text(d_playing,"<b style=\"color:purple;\">Playing now: Something that is not a file is playing</b>")
		set_text(d_name,"Name: " .. self.name,"indentandbreak")
		set_text(d_path,"Uri: " .. self.uri,"indentandbreak")
	else
		set_text(d_playing,"<b style=\"color:darkgreen;\">Playing now: A file is playing</b>")
		set_text(d_name,"Name: " .. self.name,"indentandbreak")
		set_text(d_path,"Filepath: " .. self.filepath,"indentandbreak")
	end
	vlc.msg.dbg("[FileManagement] Item:display end")
end

function event_handling(eventname)
	vlc.msg.dbg("[FileManagement] " .. eventname .. " - event_handling start")
	current = Item:new(nil)
	current:display()
	if action_waitingfornext then
		if vlc.playlist.status() == "stopped" then
			vlc.playlist.stop() -- The playlist can be temporary stopped because of an error (e.g. non-existent item in playlist or a bug in VLC (debug: 'main debug: nothing to play')). Make sure it doesn't restart in that case. Testing suggests that this solution will work to make sure the item to act upon is not locked again.
			if action_goto then -- Although this unexpected stop can be detected, no vlc.playlist.goto(action_goto) or vlc.playlist.play() is called to avoid problems with failing action or stuck action if not the expected item is played. The issue can be considered minor and will maybe be fixed in future VLC versions.
				vlc.msg.dbg("[FileManagement] " .. eventname .. " - Unexpected playlist stop detected")
			end
			vlc.msg.dbg("[FileManagement] " .. eventname .. " - Stop playlist detected - To act upon: " .. action_item.filepath)
			action_waitingfornext = false
			continuecheck()
		elseif current.uri ~= "" and current.uri ~= action_item.uri then
			vlc.msg.dbg("[FileManagement] " .. eventname .. " - New playing file detected - To act upon: " .. action_item.filepath)
			vlc.msg.dbg("[FileManagement] " .. eventname .. " - New playing file detected - New file: " .. current.filepath)
			action_waitingfornext = false
			continuecheck()
		else
			vlc.msg.dbg("[FileManagement] " .. eventname .. " - No new playing file detected - To act upon: " .. action_item.filepath)
			if current.uri == "" then
				vlc.msg.dbg("[FileManagement] " .. eventname .. " - No new playing file detected - Nothing is playing")
			end
		end
	end
	vlc.msg.dbg("[FileManagement] " .. eventname .. " - event_handling end")
end

function playing_changed()
	starttime = os.time()
	event_handling("playing_changed")
end

function meta_changed()
	starttime = os.time()
	event_handling("meta_changed")
end

function input_changed()
	starttime = os.time()
	event_handling("input_changed")
end