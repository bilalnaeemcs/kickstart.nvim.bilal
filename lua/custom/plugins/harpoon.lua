-- lua/custom/plugins/harpoon.lua
return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
    'folke/which-key.nvim',
  },
  config = function()
    local harpoon = require 'harpoon'

    -- REQUIRED: Basic harpoon setup
    harpoon:setup {
      settings = {
        save_on_toggle = true,
        sync_on_ui_close = true,
        key = function()
          return vim.loop.cwd()
        end,
      },
    }

    -- Setup number keymaps with which_key_ignore description
    vim.keymap.set('n', '<leader>1', function()
      harpoon:list():select(1)
    end, { desc = 'which_key_ignore' })
    vim.keymap.set('n', '<leader>2', function()
      harpoon:list():select(2)
    end, { desc = 'which_key_ignore' })
    vim.keymap.set('n', '<leader>3', function()
      harpoon:list():select(3)
    end, { desc = 'which_key_ignore' })
    vim.keymap.set('n', '<leader>4', function()
      harpoon:list():select(4)
    end, { desc = 'which_key_ignore' })

    -- Quick menu toggle
    vim.keymap.set('n', '<C-e>', function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = 'Harpoon quick menu' })

    -- Normal harpoon keymaps
    vim.keymap.set('n', '<leader>ha', function()
      harpoon:list():add()
    end, { desc = 'Add file' })
    vim.keymap.set('n', '<leader>hn', function()
      harpoon:list():next()
    end, { desc = 'Next file' })
    vim.keymap.set('n', '<leader>hp', function()
      harpoon:list():prev()
    end, { desc = 'Previous file' })

    -- Add remove operations
    vim.keymap.set('n', '<leader>hr', function()
      harpoon:list():remove()
    end, { desc = 'Remove current file' })
    vim.keymap.set('n', '<leader>hc', function()
      harpoon:list():clear()
    end, { desc = 'Clear all marks' })

    -- Telescope integration with remove capability
    local function toggle_telescope(harpoon_files)
      local file_paths = {}
      for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
      end

      require('telescope.pickers')
        .new({}, {
          prompt_title = 'Harpoon',
          finder = require('telescope.finders').new_table {
            results = file_paths,
          },
          previewer = require('telescope.config').values.file_previewer {},
          sorter = require('telescope.config').values.generic_sorter {},
          attach_mappings = function(prompt_bufnr, map)
            -- Add delete action in Telescope with correct remove_at method
            map('i', '<C-d>', function()
              local selection = require('telescope.actions.state').get_selected_entry()
              if selection == nil then
                return
              end
              harpoon:list():remove_at(selection.index)
              require('telescope.actions').close(prompt_bufnr)
            end)
            return true
          end,
        })
        :find()
    end

    vim.keymap.set('n', '<leader>hs', function()
      toggle_telescope(harpoon:list())
    end, { desc = 'Show marks' })

    -- Add split/tab functionality in the Harpoon window
    harpoon:extend {
      UI_CREATE = function(cx)
        vim.keymap.set('n', '<C-v>', function()
          harpoon.ui:select_menu_item { vsplit = true }
        end, { buffer = cx.bufnr })

        vim.keymap.set('n', '<C-s>', function()
          harpoon.ui:select_menu_item { split = true }
        end, { buffer = cx.bufnr })

        vim.keymap.set('n', '<C-t>', function()
          harpoon.ui:select_menu_item { tabedit = true }
        end, { buffer = cx.bufnr })
      end,
    }
  end,
}
