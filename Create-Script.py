import random

script_init = open("Script-Init.txt","r")
script_end = open("Script-End.txt","r")
script_links = open("Mod-List.txt","r")
script_file = open("Install-Mods.ps1","w")
script_cmd = "powershell -nop -ExecutionPolicy Bypass -c \"Invoke-Command -ScriptBlock ([scriptblock]::Create([System.Text.Encoding]::UTF8.GetString((New-Object Net.WebClient).DownloadData('https://github.com/TwoCanOfTuna/company-mods-install/releases/download/company-mods-install-update/Install-Mods.ps1')))) -ArgumentList @("

def add_init():
    while True:
        line = script_init.readline()
        if line == "":
            break
        script_file.write(line)

def add_end():
    while True:
        line = script_end.readline()
        if line == "":
            break
        script_file.write(line)

def add_mod(mod_link):
    global script_cmd
    
    random_number = random.randint(1,100000)
    truncated_url = mod_link[41:].split("/")
    modified_url = "https://thunderstore.io/package/download/" + truncated_url[0] + "/" + truncated_url[1] + "/$" + str(random_number) + "Version/"
    
    script_file.write("\n\n\tWrite-Host \"Downloading and installing " + str(random_number) + "\"\n")
    script_file.write("\t$" + str(random_number) + "Version = Get-Arg $arguments \"-" + str(random_number) + "\"\n")
    script_file.write("\t$" + str(random_number) + "Url = \"-" + modified_url + "\"\n")
    script_file.write("\t$" + str(random_number) + "Stream = Request-Stream $" + str(random_number) + "Url\n")
    script_file.write("\t$" + str(random_number) + "Path = Join-Path $lethalCompanyPath \"BepInEx/plugins\"\n")
    script_file.write("\tExpand-Stream $" + str(random_number) + "Stream $" + str(random_number) + "Path\n")
    script_file.write("\tWrite-Host \"Installed " + str(random_number) + "\"\n")
    script_file.write("\tWrite-Host \"\"\n")
    
    script_cmd = script_cmd + "'-" + str(random_number) + "','" + truncated_url[2] + "'"

def main():
    global script_cmd
    
    add_init()
    
    print("Enter mod download links:\n")
    first = True
    while True:
        mod_link = script_links.readline()
        print(mod_link)
        if mod_link == "":
            script_cmd = script_cmd + ")\""
            break
        if first == False:
            script_cmd = script_cmd + ","
        first = False
        add_mod(mod_link)
        
    add_end()

if __name__ == "__main__":
    main()

script_init.close()
script_file.close()
print(script_cmd)