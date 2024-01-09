import requests
from bs4 import BeautifulSoup

url_links = open("URL-List.txt", "r")
mod_links = open("Mod-List.txt", "w")

def get_download_link(url):
    html = requests.get(url)
    website_elements = BeautifulSoup(html.content, 'html.parser')
    item = website_elements.find(attrs={'class':'fa fa-download mr-2'}).parent
    mod_links.write(item.get('href') + "\n")

for line in url_links:
    data = line.split(" ")
    mod_type = data[0]
    mod_url = data[1]
    print(mod_type + " " + mod_url)
    if mod_type == "library":
        mod_links.write("library\n")
    elif mod_type == "lcapi":
        mod_links.write("lcapi\n")
    else:
        mod_links.write("plugin\n")
    get_download_link(mod_url)