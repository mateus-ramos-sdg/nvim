return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'theHamsta/nvim-dap-virtual-text',
      'nvim-telescope/telescope-dap.nvim',
      'mfussenegger/nvim-dap-python', -- Python-specific adapter
      'williamboman/mason.nvim',
      'jay-babu/mason-nvim-dap.nvim',
      'nvim-neotest/nvim-nio',
    },
    config = function()
      local mason_dap = require 'mason-nvim-dap'
      local dap = require 'dap'
      local ui = require 'dapui'
      local dap_virtual_text = require 'nvim-dap-virtual-text'
      local dap_python = require 'dap-python'

      -- Dap Virtual Text
      dap_virtual_text.setup {}

      mason_dap.setup {
        ensure_installed = { 'cppdbg', 'debugpy' }, -- Add debugpy for Python
        automatic_installation = true,
        handlers = {
          function(config)
            require('mason-nvim-dap').default_setup(config)
          end,
        },
      }

      local function get_poetry_python_path()
        local poetry_env_info = vim.fn.system 'poetry env info -p 2>/dev/null'

        -- Check if poetry env command succeeded and returned a path
        if vim.v.shell_error == 0 and poetry_env_info ~= '' then
          -- Trim any whitespace
          poetry_env_info = poetry_env_info:gsub('^%s*(.-)%s*$', '%1')
          return poetry_env_info .. '/bin/python'
        end

        -- Fallback to the regular Python path getter
        local venv_path = os.getenv 'VIRTUAL_ENV'
        if venv_path then
          return venv_path .. '/bin/python'
        end

        return vim.fn.exepath 'python3' or vim.fn.exepath 'python' or 'python'
      end

      -- Find Python path
      local function get_python_path()
        local venv_path = os.getenv 'VIRTUAL_ENV'
        if venv_path then
          return venv_path .. '/bin/python'
        end

        -- Try using the system Python
        return vim.fn.exepath 'python3' or vim.fn.exepath 'python' or 'python'
      end

      -- Set up Python adapter
      dap_python.setup(get_python_path())

      -- Python test configurations
      dap_python.test_runner = 'pytest'

      -- Add Python configuration to your existing configurations
      dap.configurations.python = {
        {
          type = 'python',
          request = 'launch',
          name = 'Poetry: Launch file',
          program = '${file}',
          pythonPath = get_poetry_python_path,
          cwd = '${workspaceFolder}',
          -- Poetry-specific environment setup
          -- env = function()
          --   -- Optional: Add any Poetry-specific environment variables here
          --   return {
          --     -- You can add environment variables here if needed
          --     -- EXAMPLE_VAR = "value",
          --   }
          -- end,
        },
        {
          type = 'python',
          request = 'launch',
          name = 'Launch file',
          program = '${file}',
          pythonPath = get_python_path,
        },
        {
          type = 'python',
          request = 'launch',
          name = 'Launch with arguments',
          program = '${file}',
          args = function()
            local args_string = vim.fn.input 'Arguments: '
            return vim.split(args_string, ' ')
          end,
          pythonPath = get_python_path,
        },
        {
          type = 'python',
          request = 'attach',
          name = 'Attach remote',
          connect = {
            host = function()
              return vim.fn.input('Host [127.0.0.1]: ', '127.0.0.1')
            end,
            port = function()
              return tonumber(vim.fn.input('Port [5678]: ', '5678'))
            end,
          },
          pythonPath = get_python_path,
          justMyCode = false,
        },
      }

      -- Keep your existing C/C++ configurations
      dap.configurations.c = {
        {
          name = 'Launch file',
          type = 'cppdbg',
          request = 'launch',
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopAtEntry = false,
          MIMode = 'lldb',
        },
        {
          name = 'Attach to lldbserver :1234',
          type = 'cppdbg',
          request = 'launch',
          MIMode = 'lldb',
          miDebuggerServerAddress = 'localhost:1234',
          miDebuggerPath = '/usr/bin/lldb',
          cwd = '${workspaceFolder}',
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
        },
      }

      -- Dap UI setup
      ui.setup()

      vim.fn.sign_define('DapBreakpoint', { text = '🔴' })

      -- UI listeners
      dap.listeners.before.attach.dapui_config = function()
        ui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        ui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        ui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        ui.close()
      end

      -- Set up keymaps
      vim.keymap.set('n', '<F5>', function()
        dap.continue()
      end, { desc = 'Debug: Continue' })
      vim.keymap.set('n', '<F10>', function()
        dap.step_over()
      end, { desc = 'Debug: Step Over' })
      vim.keymap.set('n', '<F11>', function()
        dap.step_into()
      end, { desc = 'Debug: Step Into' })
      vim.keymap.set('n', '<F12>', function()
        dap.step_out()
      end, { desc = 'Debug: Step Out' })
      vim.keymap.set('n', '<leader>db', function()
        dap.toggle_breakpoint()
      end, { desc = 'Debug: Toggle Breakpoint' })
      vim.keymap.set('n', '<leader>dB', function()
        dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end, { desc = 'Debug: Set Conditional Breakpoint' })
      vim.keymap.set('n', '<leader>dp', function()
        dap.set_breakpoint(nil, nil, vim.fn.input 'Log point message: ')
      end, { desc = 'Debug: Set Log Point' })
      vim.keymap.set('n', '<leader>dr', function()
        dap.repl.open()
      end, { desc = 'Debug: Open REPL' })
      vim.keymap.set('n', '<leader>dl', function()
        dap.run_last()
      end, { desc = 'Debug: Run Last' })

      -- Python-specific keymaps
      vim.keymap.set('n', '<leader>dpt', function()
        dap_python.test_method()
      end, { desc = 'Debug: Python Test Method' })
      vim.keymap.set('n', '<leader>dpc', function()
        dap_python.test_class()
      end, { desc = 'Debug: Python Test Class' })
      vim.keymap.set('n', '<leader>dps', function()
        dap_python.debug_selection()
      end, { desc = 'Debug: Python Selection' })
    end,
  },
}
