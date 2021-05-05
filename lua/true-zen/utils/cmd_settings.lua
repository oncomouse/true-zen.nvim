

local cmd = vim.cmd
local opts = require("true-zen.config").options
local before_after_cmds = require("true-zen.utils.before_after_cmd")


local function test_bool(final_opt, var)
	
	if (var == true) then
		return "setlocal "..final_opt..""
	elseif (var == false) then
		return "setlocal no"..final_opt..""
	end

end

local function test_num(final_opt, num)
	return "setlocal "..final_opt.."="..num..""
end

local function test_str(final_opt, str)
	return "setlocal "..final_opt.."="..str..""
end

local function clean_and_exec(opt, table_opt, remove_str)
	final_opt = opt:gsub(remove_str, "")
	if (type(table_opt) == "boolean") then
		to_cmd = test_bool(final_opt, table_opt)
		cmd(to_cmd)
	elseif (type(table_opt) == "number") then
		to_cmd = test_num(final_opt, table_opt)
		cmd(to_cmd)
	elseif (type(table_opt) == "string") then
		to_cmd = test_str(final_opt, table_opt)
		cmd(to_cmd)
	end
end


function map_settings(table, bool, ui_element)

	ui_element = ui_element or "NONE"


	if (bool == true) then

		if (opts["minimalist"]["store_and_restore_settings"] == true) then
			before_after_cmds.restore_settings(ui_element)
		else
			for opt, _ in pairs(table) do
				if string.find(opt, "shown_") then
					clean_and_exec(opt, table[opt], "shown_")
				else
					-- skip the option
				end
			end
		end



	elseif (bool == false) then

		if (opts["minimalist"]["store_and_restore_settings"] == true) then
			before_after_cmds.store_settings(table, ui_element)
		end

		for opt, _ in pairs(table) do
			if string.find(opt, "hidden_") then
				clean_and_exec(opt, table[opt], "hidden_")
			else
				-- skip the option
			end
		end
	end
end



return {
	map_settings = map_settings
}
