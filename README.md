Provides the ability to run [Gradle](http://www.gradle.org/ "Home - Gradle") commands from within [TextMate](http://macromates.com/ "TextMate — The Missing Editor for Mac OS X").

> To use this bundle, you **MUST** have the Gradle wrapper script (i.e. `gradlew`) installed at the root of the directory that you have open in TextMate.

## Running commands

To run a Gradle command, with any file open, press `⌃⌘G` (`control` + `command` + `G`) to bring up the Gradle task menu. 

![Gradle Commands](https://github.com/alkemist/gradle.tmbundle/raw/master/screenshots/commands.png)

There is a predefined set of common tasks, and a “Run Command…” item that will prompt with a dialog where you can enter the arguments to be passed to `gradlew`.

![prompt](https://github.com/alkemist/gradle.tmbundle/raw/master/screenshots/projectPrompt.png)

![output](https://github.com/alkemist/gradle.tmbundle/raw/master/screenshots/projectCommandOutput.png)

The command menu contains items with `(module)` and `(project)` suffixes. The _module_ commands target the module of the currently selected file in the editor, while the _project_ commands operate on the root project.

![prompt](https://github.com/alkemist/gradle.tmbundle/raw/master/screenshots/modulePrompt.png)

![output](https://github.com/alkemist/gradle.tmbundle/raw/master/screenshots/moduleCommandOutput.png)

The “Run Previous Command” item will always re-run the most recently executed command, regardless of whether it was a project or module targeted command.

> The current mechanism for finding the module for the open file relies on a `build.gradle` file being present in the module directory, and the name of the module being the logical name based on the directory's location in the project. This will be improved in future versions of this bundle.

## Running A Single Test

The “Test Selected File” command runs the command to run the open file in the editor as the single test…

![prompt](https://github.com/alkemist/gradle.tmbundle/raw/master/screenshots/singleTestCommand.png)

![prompt](https://github.com/alkemist/gradle.tmbundle/raw/master/screenshots/singleTestOutput.png)

## Output Filtering Features

![prompt](https://github.com/alkemist/gradle.tmbundle/raw/master/screenshots/successfulOutput.png)

### Compile Errors

The filename and line number of output as part of each compile error for Java and Groovy source is a link that will take you to the line of the file which the compile error.

![prompt](https://github.com/alkemist/gradle.tmbundle/raw/master/screenshots/compileErrorOutput.png)

### Failed Tests

The output message for each individual test class failure is linked to the corresponding XML test report which will open in TextMate when clicked.

The output message pointing to the HTML test report on test failure is converted into a link that when clicked opens the test report in your browser.

![prompt](https://github.com/alkemist/gradle.tmbundle/raw/master/screenshots/failedTestOutput.png)
