import os
import subprocess
from datetime import datetime

# Repository directory
REPO_DIR = "/root/palweed-server"
BACKUP_DIR = os.path.join(REPO_DIR, "palworld/backups")  # Backup folder
BRANCH_NAME = "main"  # Use main branch

# Function to create a backup using Docker
def create_backup():
    print("Creating backup using Docker...")
    subprocess.run(["docker", "exec", "palworld-server", "backup"], check=True)

    # Find the latest backup file
    latest_backup = max(
        (os.path.join(BACKUP_DIR, f) for f in os.listdir(BACKUP_DIR) if f.endswith(".tar.gz")),
        key=os.path.getctime
    )
    print(f"Latest backup created: {latest_backup}")
    return os.path.basename(latest_backup)

# Function to handle Git commit and push
def git_push(backup_file):
    print("Switching to the 'main' branch")
    subprocess.run(["git", "checkout", BRANCH_NAME], cwd=REPO_DIR, check=True)

    print("Adding the new backup")
    subprocess.run(["git", "add", "-f", f"palworld/backups/{backup_file}"], cwd=REPO_DIR, check=True)

    print("Committing changes")
    subprocess.run(["git", "commit", "-m", f"chore: backup created at {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"],
                   cwd=REPO_DIR, check=True)

    print("Pushing to remote repository")
    subprocess.run(["git", "push", "origin", BRANCH_NAME], cwd=REPO_DIR, check=True)

# Main function to orchestrate the process
def main():
    try:
        backup_file = create_backup()
        git_push(backup_file)
        print("Backup and push completed successfully!")
    except subprocess.CalledProcessError as e:
        print(f"Error during backup or git push: {e}")

if __name__ == "__main__":
    main()
