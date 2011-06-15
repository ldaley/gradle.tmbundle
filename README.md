Provides the ability to run [Gradle](http://www.gradle.org/ "Home - Gradle") commands from within [TextMate](http://macromates.com/ "TextMate — The Missing Editor for Mac OS X").

> To use this bundle, you **MUST** have the Gradle wrapper script (i.e. `gradlew`) installed at the root of the directory that you have open in TextMate.

## Running commands

To run a Gradle command, with any file open, press `⌃⌘G` (`control` + `command` + `G`) to bring up the Gradle task menu. 

![Gradle Commands](https://github.com/alkemist/gradle.tmbundle/raw/master/screenshots/commands.png)

There is a predefined set of common tasks, and a “Run Command…” item that will prompt with a dialog where you can enter the arguments to be passed to `gradlew`.

![prompt](https://github.com/alkemist/gradle.tmbundle/raw/master/screenshots/projectPrompt.png)

![output](https://github.com/alkemist/gradle.tmbundle/raw/master/screenshots/projectCommandOutput.png)

### Targeting

The command menu contains items with `(module)` and `(project)` suffixes. The _module_ commands target the module of the currently selected file in the editor, while the _project_ commands operate on the root project.

> The current mechanism for finding the module for the open file relies on a `*.gradle` file being present in the module directory.

![prompt](https://github.com/alkemist/gradle.tmbundle/raw/master/screenshots/modulePrompt.png)

![output](https://github.com/alkemist/gradle.tmbundle/raw/master/screenshots/moduleCommandOutput.png)

### Project Structure

The default behaviour is to determine the module name by taking it's relative path from the project root and substituting the forward slashes with colons. So given the following project structure…

    modules/module-a
    modules/module-b

The bundle will use the following as the names for the modules…

    modules:module-a
    modules:module-b

However you may have your `settings.gradle` file configured to use a different convention. If so, you need to provide a “transformer” script that generates the right module names. You might want the names to be `module-a` and `module-b` (i.e. no *modules* prefix). Your `settings.gradle` would look like…

    include 'module-a', 'module-b'
    
    rootProject.children.each { project ->
        project.projectDir = new File(settingsDir, "modules/$fileBaseName")
    }

> See the [Gradle User Guide section on settings.gradle](http://www.gradle.org/latest/docs/userguide/userguide_single.html#sec:settings_file) for more on configuration of project structure.

So TextMate can correctly target the module you are asking it to, you need to create a script that takes the module path as input and writes its name as output. This script must be located at `.textmate/transform-gradle-project-path` in the root of the project. For our custom project structure outlined above, this file would look like…

    #!/usr/bin/env ruby
    
    path = STDIN.read
    puts path.start_with? "modules:" ? path.sub /^modules:/, "" : path

We are using Ruby here, but it could be anything… it just needs to be an exectuable that takes the default assumed path (i.e. `modules:module-a`) as input and transforms it into the appropriate path (i.e. `module-a`). 

### The Previous Command

The “Run Previous Command” item will always re-run the most recently executed command, regardless of whether it was a project or module targeted command.

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

## Notifications

At the end of the command, a Growl notification will be raised with the result of the command.

![prompt](https://github.com/alkemist/gradle.tmbundle/raw/master/screenshots/growlNotifications.png)
