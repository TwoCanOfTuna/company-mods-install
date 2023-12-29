from random_word import RandomWords
random_words = RandomWords()

script_init = open("Script-Init.txt","r")
script_end = open("Script-End.txt","r")
script_links = open("Mod-List.txt","r")
script_file = open("Install-Mods.ps1","w")
script_cmd = "powershell -nop -ExecutionPolicy Bypass -c \"Invoke-Command -ScriptBlock ([scriptblock]::Create([System.Text.Encoding]::UTF8.GetString((New-Object Net.WebClient).DownloadData('https://github.com/TwoCanOfTuna/company-mods-install/releases/download/company-mods-install-vnx/Install-Mods.ps1')))) -ArgumentList @("

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

def add_mod(mod_link, mod_type):
    global script_cmd
    
    rand = random_words.get_random_word()
    truncated_url = mod_link[41:].split("/")
    modified_url = "https://thunderstore.io/package/download/" + truncated_url[0] + "/" + truncated_url[1] + "/$" + str(rand) + "Version/"
    
    script_file.write("\n\n\tWrite-Host \"Downloading and installing " + str(rand) + "\"\n")
    script_file.write("\t$" + str(rand) + "Version = Get-Arg $arguments \"-" + str(rand) + "\"\n")
    script_file.write("\t$" + str(rand) + "Url = \"" + modified_url + "\"\n")
    script_file.write("\t$" + str(rand) + "Stream = Request-Stream $" + str(rand) + "Url\n")
    if(mod_type == "library\n"):
        script_file.write("\t$" + str(rand) + "Path = Join-Path $lethalCompanyPath \"BepInEx\"\n")
    else:
        script_file.write("\t$" + str(rand) + "Path = Join-Path $lethalCompanyPath \"BepInEx/plugins\"\n")
    script_file.write("\tExpand-Stream $" + str(rand) + "Stream $" + str(rand) + "Path\n")
    script_file.write("\tWrite-Host \"Installed " + str(rand) + "\"\n")
    script_file.write("\tWrite-Host \"\"")
    
    script_cmd = script_cmd + "'-" + str(rand) + "','" + truncated_url[2] + "'"

def main():
    global script_cmd
    
    add_init()
    
    print("Enter mod download links:\n")
    first = True
    while True:
        mod_type = script_links.readline()
        mod_link = script_links.readline()
        print(mod_link)
        if mod_link == "":
            script_cmd = script_cmd + ")\""
            break
        if first == False:
            script_cmd = script_cmd + ","
        first = False
        add_mod(mod_link, mod_type)
        
    add_end()

if __name__ == "__main__":
    main()

script_init.close()
script_file.close()
print(script_cmd)