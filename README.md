Provides the ability to run [Gradle](http://www.gradle.org/ "Home - Gradle") commands from within [TextMate](http://macromates.com/ "TextMate — The Missing Editor for Mac OS X").

## Running commands

To run a Gradle command, with any file open, press `⌃⌘G` (`control` + `command` + `G`). You'll be prompted with a dialog where you can enter the arguments to be passed to `gradlew`. The dialog will prepopulated with the previous Gradle command.

To use this feature, you **MUST** have the Gradle wrapper script (i.e. `gradlew`) installed at the root of the directory that you have open in TextMate.

## Output Filtering Features

### Compile Errors

The filename and line number of output as part of each compile error for Java and Groovy source is a link that will take you to the line of the file which the compile error.

### Failed Tests

The output message for each individual test class failure is linked to the corresponding XML test report which will open in TextMate when clicked.

The output message pointing to the HTML test report on test failure is converted into a link that when clicked opens the test report in your browser.