@echo off
echo This utility combines the source files for echo3 into one javascript 
echo file. After you run this. Compress the output file with a javascript 
echo compressor and save the compressed verion of the file as 
echo echo3_compressed.js 
echo Working...
type corejs\Core.js > echo3_complete.js
type corejs\Core.Web.js >> echo3_complete.js
type echo\Application.js >> echo3_complete.js
type echo\Render.js >> echo3_complete.js
type echo\Sync.js >> echo3_complete.js
type echo\Sync.Label.js >> echo3_complete.js
type echo\Client.js >> echo3_complete.js
type echo\Serial.js >> echo3_complete.js
type echo\FreeClient.js >> echo3_complete.js
type echo\Arc.js >> echo3_complete.js
type echo\DebugConsole.js >> echo3_complete.js
type echo\Sync.ArrayContainer.js >> echo3_complete.js
type echo\Sync.Button.js >> echo3_complete.js
type echo\Sync.Composite.js >> echo3_complete.js
type echo\Sync.ContentPane.js >> echo3_complete.js
type echo\Sync.Grid.js >> echo3_complete.js
type echo\Sync.List.js >> echo3_complete.js
type echo\Sync.SplitPane.js >> echo3_complete.js
type echo\Sync.TextComponent.js >> echo3_complete.js
type echo\Sync.ToggleButton.js >> echo3_complete.js
type echo\Sync.WindowPane.js >> echo3_complete.js

type extras\Extras.js >> echo3_complete.js
type extras\Application.AccordionPane.js >> echo3_complete.js
type extras\Application.BorderPane.js >> echo3_complete.js
type extras\Application.CalendarSelect.js >> echo3_complete.js
type extras\Application.ColorSelect.js >> echo3_complete.js
type extras\Application.DataGrid.js >> echo3_complete.js
type extras\Application.DragSource.js >> echo3_complete.js
type extras\Application.Group.js >> echo3_complete.js
type extras\Application.Menu.js >> echo3_complete.js
type extras\Application.RichTextArea.js >> echo3_complete.js
type extras\Application.RichTextInput.js >> echo3_complete.js
type extras\Application.TabPane.js >> echo3_complete.js
type extras\Application.ToolTipContainer.js >> echo3_complete.js
type extras\Application.TransitionPane.js >> echo3_complete.js
type extras\Serial.Menu.js >> echo3_complete.js
type extras\Sync.AccordionPane.js >> echo3_complete.js
type extras\Sync.BorderPane.js >> echo3_complete.js
type extras\Sync.CalendarSelect.js >> echo3_complete.js
type extras\Sync.ColorSelect.js >> echo3_complete.js
type extras\Sync.DataGrid.js >> echo3_complete.js
type extras\Sync.DragSource.js >> echo3_complete.js
type extras\Sync.Group.js >> echo3_complete.js
type extras\Sync.Menu.js >> echo3_complete.js
type extras\Sync.RichTextArea.js >> echo3_complete.js
type extras\Sync.RichTextInput.js >> echo3_complete.js
type extras\Sync.TabPane.js >> echo3_complete.js
type extras\Sync.ToolTipContainer.js >> echo3_complete.js
type extras\Sync.TransitionPane.js >> echo3_complete.js
type extras\SyncLocale.CalendarSelect.de.js >> echo3_complete.js
type extras\SyncLocale.RichTextArea.de.js >> echo3_complete.js
echo Done! :) -=\jEgAs/=-

