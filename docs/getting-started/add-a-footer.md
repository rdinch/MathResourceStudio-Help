# Add a footer

The Footer area is located at the very bottom of a document page. By default a very simple footer is added to the bottom of the page starting on page one.

To access the Footer editor, a math document must be open. Select Footer in the Document area of the ribbon to open the editor.

!!! tip
    When the footer is displayed on a page, double-click anywhere in the footer to open the Footer editor.

## Collapse All or Expand All Options

The Footer editor has a large list of options that can be customized. Select the Collapse All icon on the ribbon to simplify the view so you can focus on a particular area. Select the Expand All icon so all the available options can be viewed.

## Saving the Footer Options or Reset to Defaults

### Save and Save As

Multiple customized sets of footer options can be saved and used on both the worksheet and answer sheet. Use Save or Save As to save the current set of options.

### Open

Use Open to select a previously saved set of footer options.

### Reset

Select Reset at any time to return all footer options back to default settings.

## General

### Visible

By default, a footer appears on the first and subsequent pages of a multi-page math document. Uncheck Visible to hide the footer on all pages.

### Start page

By default the footer starts on page 1 of a multi-page math document. Select between page 1 or page 2 for the footer to start.

### Count from page

When using the Auto Page Numbering tag in the footer, this option specifies which page number the count should begin with. This is useful when combining multiple math documents into a single package after printing.

### Padding

This option sets the extra white space between the footer and the math questions. Use the up arrow to increase the space and the down arrow to decrease the space, or type in a number within the range. Range is 0 to 100.

## Picture

By default, the picture is not visible in the footer. You can include a picture using any of these formats: .bmp, .emf, .jpg/jpeg, .gif, .png, .tif/tiff, .wmf.

### Show or hide picture

By default the picture is hidden. Check Visible to display the picture.

### Change the alignment

Select between the following alignments for the picture: Left, Center, Right.

### Change the picture

Select Image in the options, then press the ellipsis button (...) to display the **[Picture Editor](../tutorials/picture-editor.md)** to choose a different picture.

!!! tip
    When selecting a picture to use in the footer, change Adjusted Image Height to control the size of the picture; DO NOT RESIZE the picture size in the Picture Editor.

### Adjust the size of the picture

The information in Original Image Height is provided as a reference only and cannot be edited. The option Adjusted Image Height re-sizes the image in the footer. The picture width will automatically be adjusted to maintain the image's aspect ratio. This setting only adjusts the size of the picture in the footer; the original image in the Picture Editor is not changed.

!!! tip
    When selecting a picture to use in the footer, change Adjusted Image Height to control the size of the picture; DO NOT RESIZE the picture size in the Picture Editor.

## Text Fields

### Customize the text fields

The text fields in the footer can be completely customized. Suggested data has been entered. If a field is left blank, a blank space appears on the document. If all Top fields - or all Bottom fields - are left blank the other text fields move up or down to fill in the space. You can also use these special auto content tags for any field:

- *Date*: The tags `<d>` and `<D>` can be typed into any of the text fields to insert today's date. Or add days to the date using this format: `<d+2>`, `<D+5>`. Each tag provides a different date format: `<d>` - results in a date format using just numbers, such as 06/06/2010; `<D>` - results in a date format that uses the name of the month, such as June 06, 2010.

    !!! note
        Date formatting is based on the computer's operating system Regional Settings. Date format varies between countries. Your local date formatting from Regional Settings will be used, and it may not match the sample provided above.

- *Auto Page Numbering*: The tag `<p>` can be typed into any of the text fields to have the appropriate page number appear on each page. You can also use the tag `<tp>` to display the total number of pages for the document. You can combine these tags to show the current page along with the total number of pages. Other characters can also be used along with these tags. Example: **Page `<p>` of `<tp>`** will appear as **Page 3 of 27** in the footer.

- *Total Marks*: The tag `<tm>` can be typed into any of the text fields to display the total marks for all exercise sets included in the document. You can use this tag along with other characters. Example: If the total marks for a document are 30, **Total Marks - `<tm>`** will appear as **Total Marks - 30**.

- *File Name and File Path*: Type `<f>` into any field to display the name of the saved math file in the footer. Use `<F>` to display the full path to the saved file on the computer.

- *Serial Number (SN)*: Type `<sn>` to add the serial number of the document to the footer. Serial numbers are generated automatically and can be adjusted manually from the display bar located at the bottom of the Math program window.

- *Version Number*: Type the tag `<v>` to add a version number to the footer. The version number can be manually updated from the display bar at the bottom of the Math program window.

    !!! tip
        If you use Regenerate Between Copies when printing the math document, the version number will be automatically updated after each regeneration.

### Change the text font

1. Select Font in the options pane and press the ellipsis button (...) to display the font selection dialog.

2. Select the preferred font name, style, and size.

3. Click OK to close the dialog and apply the selected font.

### Change the text color

1. Select Field Color in the options pane and press the ellipsis button (...) to display the color dialog.

2. Choose a color from either the Basic or Web selections.

3. Click OK to save your choice and apply the new color.

## Line

### Display a line above the footer

A line can be added above the footer area. Check Visible to display the line.

### Change the line color

1. Select Color in the options pane and press the ellipsis button (...) to display the color dialog.

2. Choose a color from either the Basic or Web selections.

3. Click OK to save your choice and apply the new color.

### Change the line width

1. Click on Width in the options pane.

2. Type a number between 0 and 10, or use the up/down arrows to adjust the width of the line.

### Adjust the padding

Padding is the extra white space between the line and rest of the footer in 100ths of an inch (25 = 1/4 inch, 40 = 1 cm).

1. Select Padding in the options pane.

2. Type a new value in the input field or use the up and down arrows to increase or decrease the value. Valid range: 0 to 50.
