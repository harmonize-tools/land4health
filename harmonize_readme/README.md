# Harmonize github page configuration
![Harmonize Logo](/harmonize_readme/images/logo_harmonize.png)

Welcome to our project! This guide will help you set up the necessary configuration files, insert images into your README, and set up Git hooks for your repository. Follow the steps below to get started 🚀.

## Mandatory Files

You need to create two mandatory files:

1. **config.json**

    Create a file named `config.json` with the following content:

    ```json
    {
      "links": [
        {
          "text": "Harmonize web page",
          "link": "https://www.harmonize-tools.org/"
        }
      ],
      "licenses": [
        {
          "text": "MIT",
          "link": "https://opensource.org/license/mit/"
        }
      ],
      "citations": [
        {
          "text": "Citing of drone use",
          "link": "https://scholar.google.es/scholar?q=info:8PmRaTkPC2IJ:scholar.google.com/&output=cite&scirp=0&hl=es"
        }
      ],
      "authors": [
        {
          "name": "Raphael Saldanha",
          "position": "Author, maintainer"
        }
      ],
      "badges": [
        {
          "classname": "mb-2 w-24",
          "src": "https://www.r-pkg.org/badges/version/brclimr",
          "alt": "CRAN status"
        },
        {
          "classname": "mb-2 w-40",
          "src": "https://cranlogs.r-pkg.org/badges/brclimr",
          "alt": "CRAN status"
        },
        {
          "classname": "w-36",
          "src": "https://github.com/rfsaldanha/brclimr/actions/workflows/R-CMD-check.yaml/badge.svg",
          "alt": "R-CMD-check"
        }
      ]
    }
    ```

2. **README.md**

    Create a `README.md` file indicating the paths of the images inside the `harmonize_readme` folder. Here's an example structure:

    ```markdown
    # Project Title

    ![Harmonize Logo](harmonize_readme/harmonize_logo.png)

    This project is about...

    ## Images

    - ![Diagram](harmonize_readme/diagram.png)
    - ![Screenshot](harmonize_readme/screenshot.png)
    ```

## Setting Up Git Hooks

To automate certain tasks upon committing changes, follow these steps to set up a Git hook:

1. In the main folder of your project, navigate to the `.git/hooks` directory. If it doesn't exist, create it. You can use the command `ls -la` to see hidden files and directories.

2. Create a file named `post-commit` in the `.git/hooks` directory.

3. Make the `post-commit` file executable by running:

    ```bash
    chmod +x post-commit
    ```

4. Add the following content to the `post-commit` file, replacing `git@github.com:user/repo.git` with the SSH URL of your repository:

    ```bash
    #!/bin/bash
    
    # Define the GitHub repository URL
    GITHUB_REPO="git@github.com:user/repo.git"
    
    # Push changes to the GitHub repository
    git push "$GITHUB_REPO" main
    ```

Once set up, every commit you make to the main branch will automatically synchronize with your specified repository.

## Committing the Hooks Folder

If you want to commit the hooks folder to your repository:

1. Create a new folder in your repository and copy the scripts from the `.git/hooks` directory into this new folder.

2. Specify the new location of the hooks files by running:

    ```bash
    git config --local core.hooksPath path_to_new_folder
    ```

Remember that each user must perform this setup, so include these
