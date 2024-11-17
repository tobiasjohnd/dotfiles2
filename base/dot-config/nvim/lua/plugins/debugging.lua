return {
    "rcarriga/nvim-dap-ui",
    dependencies = {
	"mfussenegger/nvim-dap",
	"nvim-neotest/nvim-nio"
    },
    config = function()
	local dapui = require("dapui")
	local dap = require("dap")

	dap.adapters.gdb = {
	    type = "executable",
	    command = "gdb",
	    args = { "-i", "dap" }
	}

	dap.configurations.cpp = {
	    {
		name = 'Run executable (GDB)',
		type = 'gdb',
		request = 'launch',
		-- This requires special handling of 'run_last', see
		-- https://github.com/mfussenegger/nvim-dap/issues/1025#issuecomment-1695852355
		program = function()
		    local path = vim.fn.input({
			prompt = 'Path to executable: ',
			default = vim.fn.getcwd() .. '/',
			completion = 'file',
		    })

		    return (path and path ~= '') and path or dap.ABORT
		end,
	    },
	    {
		name = 'Run executable with arguments (GDB)',
		type = 'gdb',
		request = 'launch',
		-- This requires special handling of 'run_last', see
		-- https://github.com/mfussenegger/nvim-dap/issues/1025#issuecomment-1695852355
		program = function()
		    local path = vim.fn.input({
			prompt = 'Path to executable: ',
			default = vim.fn.getcwd() .. '/',
			completion = 'file',
		    })

		    return (path and path ~= '') and path or dap.ABORT
		end,
		args = function()
		    local args_str = vim.fn.input({
			prompt = 'Arguments: ',
		    })
		    return vim.split(args_str, ' +')
		end,
	    },
	    {
		name = 'Attach to process (GDB)',
		type = 'gdb',
		request = 'attach',
		processId = require('dap.utils').pick_process,
	    },
	}

	require("dapui").setup()
	dap.listeners.before.attach.dapui_config = function()
	    dapui.open()
	end
	dap.listeners.before.launch.dapui_config = function()
	    dapui.open()
	end
	dap.listeners.before.event_terminated.dapui_config = function()
	    dapui.close()
	end
	dap.listeners.before.event_exited.dapui_config = function()
	    dapui.close()
	end
    end
}
