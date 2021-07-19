local service = require("true-zen.services.modes.mode-ataraxis.service")
local opts = require("true-zen.config").options
local truezen = require("true-zen")

local api = vim.api
local fn = vim.fn
local cmd = vim.cmd
local status_mode_ataraxis

local M = {}

local function get_status()
    return status_mode_ataraxis
end

local function set_status(value)
    status_mode_ataraxis = value
end

local function autocmds(state)
    if (state == "start") then
        api.nvim_exec(
            [[
			augroup truezen_mode_ataraxis_resume
				autocmd!
				autocmd WinEnter * if exists("w:truezen_window") | execute "lua require'true-zen.services.modes.mode-ataraxis.init'.resume()" | endif
			augroup END
		]],
            false
        )

        local quit_opt = opts["modes"]["ataraxis"]["quit"]
        local quit_cmd

        if (quit_opt ~= nil) then
            if (quit_opt == "untoggle") then
                quit_cmd = [[execute "lua require'true-zen.services.modes.mode-ataraxis.init'.main('off')"]]
            elseif (cmd == "close") then
                quit_cmd = [[execute "lua require'true-zen.services.modes.mode-ataraxis.init'.main('off')" | quit]]
            end

			api.nvim_exec(
				[[
				augroup truezen_mode_ataraxis_quit
					autocmd!
					autocmd QuitPre * ]] .. quit_cmd .. [[
				augroup END
			]],
				false
			)
        end

    elseif (state == "stop") then
        api.nvim_exec([[
			augroup truezen_mode_ataraxis_resume
				autocmd!
			augroup END
		]], false)


		if (opts["modes"]["ataraxis"]["quit"] ~= nil) then
			api.nvim_exec([[
				augroup truezen_mode_ataraxis_quit
					autocmd!
				augroup END
			]], false)
		end

    end
end

local function on()
    if (truezen.before_mode_ataraxis_on ~= nil) then
        truezen.before_mode_ataraxis_on()
    end

    service.on()
    autocmds("start")
    set_status("on")

    if (truezen.after_mode_ataraxis_on ~= nil) then
        truezen.after_mode_ataraxis_on()
    end
end

local function off()
    if (truezen.before_mode_ataraxis_off ~= nil) then
        truezen.before_mode_ataraxis_off()
    end

    autocmds("stop")
    service.off()
    set_status("off")

    if (truezen.after_mode_ataraxis_off ~= nil) then
        truezen.after_mode_ataraxis_off()
    end
end

function M.resume()
    if (service.get_layout() ~= api.nvim_eval("winrestcmd()")) then
        autocmds("stop")

        cmd([[call g:TrueZenWinDo("if !exists('w:truezen_window') | :q | endif")]])
        cmd(service.get_layout())
        cmd([[call win_gotoid(g:truezen_main_window)]])

        autocmds("start")
    end
end

local function toggle()
    if (get_status() == "on") then
        off()
    else
        on()
    end
end

function M.main(option)
    option = option or 0

    if (option == "toggle") then
        toggle()
    elseif (option == "on") then
        on()
    elseif (option == "off") then
        off()
    end
end

return M
