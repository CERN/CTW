var filename = arguments[0];
var exportDir = arguments[1];

print('Loading world ' + filename);
var world = wp.getWorld()
    .fromFile(filename) // The filename of the world to load; may be absolute or relative to the current directory
    .go();

print('Exporting world to ' + exportDir);
wp.exportWorld(world) 
    .toDirectory(exportDir) 
    .go();

print('Export completed')

