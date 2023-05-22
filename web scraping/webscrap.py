import time
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import tqdm
import pickle
from getonesite import getonesite
import pandas as pd
from get_urls import get_urls

# configure webdriver
options = Options()
options.add_argument("--window-size=700,1080")
options.add_argument("start-maximized")
options.add_argument("--headless")
driver = webdriver.Chrome(options=options)

result_dataframe = pd.DataFrame({'url': [], 'job title': [], 'address': [], 'remote': [], 'salary': [], 'pay': [],
                                 'contract': [], 'company': [], 'exp lvl': [], 'company size': [], 'tech stack': [],
                                 'description': []})
result_dataframe.to_csv('result_test.csv', index=False)

driver.get("https://justjoin.it")
time.sleep(5)

urls_list = get_urls(driver)
# with open('urls_list.pkl', 'rb') as f:
#     urls_list = pickle.load(f)

failed_urls = []
pbar2 = tqdm.tqdm(total=len(urls_list))
for url in list(urls_list):
    try:
        row = getonesite(driver, "https://justjoin.it" + url)
        row.to_csv('result_test.csv', mode='a', header=False, index=False)
        # result_dataframe = result_dataframe.append(row)
    except Exception:
        failed_urls.append(url)
        print("failed:", url)
    pbar2.update(1)
pbar2.close()

with open("failed_urls.txt", "w") as f:
    f.writelines(failed_urls)

# result_dataframe.to_csv("scraped_data.csv", index=False)
