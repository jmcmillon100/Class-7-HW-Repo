Step 1 : Open your machine's Command Line(These instructions are tailored to MAC, but operate accordingly).

Step 2: Navigate into whatever location you want to house your terraform directory.Then use the "mkdir <dir_name>" command to make a directory to house your terraform folder.

Step 3: Navigate into your new directory and use the "touch" command to create a file named "auth.tf".

Step 4: Make sure you are in your directiory and can see your "auth.tf" file through the command line when you do the "ls command".

Step 5: Enter "code ." to open VS code, then check that your are working inside of your "auth.tf" file. 

Step 6: Copy and paste the following code below into your "auth.tf" file.

provider "aws" {
  region = "eu-west-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
} 

After pasting in the raw code file press "cmd + s" t save your sile or navigate through the "file" section at the top of your screen.

Step 7: Navigate to the top of your screen and press the "Terminal" section and click "New Terminal". A new terminal should open at the bottom of your screen.

Step 8: click inside the terminal and then type the command "terraform init" and press enter. So text will then pop up and if everything has been done correctly up to this point you will see "Terraform has been successfully initalized!"


Step 9:

Step 10: