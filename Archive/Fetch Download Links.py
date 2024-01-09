import requests
from bs4 import BeautifulSoup

company_mods_path = "C:\\Users\\Kevin\\Code\\company-mods-install"
url_links = open(company_mods_path + "\\URL-List.txt", "r")
mod_links = open(company_mods_path + "\\Mod-List.txt", "w")
num_libraries = 2
lines_written = 0

def get_download_link(url):
    html = requests.get(url)
    website_elements = BeautifulSoup(html.content, 'html.parser')
    item = website_elements.find(attrs={'class':'fa fa-download mr-2'}).parent
    mod_links.write(item.get('href') + "\n")

for url in url_links:
    if lines_written < num_libraries:
        mod_links.write("library\n")
    else:
        mod_links.write("plugin\n")
    get_download_link(url)
    lines_written = lines_written + 1