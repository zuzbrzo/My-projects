from selenium.webdriver.common.by import By
import pickle
import tqdm
import time
from parsel import Selector

def get_urls(driver):
    urls_list = set()
    scrollable = driver.find_element(By.CLASS_NAME, 'css-ic7v2w')
    offer_height = 68

    pbar1 = tqdm.tqdm(total=500)  # nie wiadomo ile dokładnie jest ofert
    while True:
        old_len = len(urls_list)
        temp_bottom = old_len * offer_height
        driver.execute_script(f"arguments[0].scrollTop = {temp_bottom}", scrollable)
        time.sleep(2)

        sel = Selector(text=driver.page_source)
        for item in sel.xpath("//div[contains(@class,'css-ic7v2w')]//div//div//div/a/@href"):
            url_temp = item.get()
            urls_list.add(url_temp)

        pbar1.update(1)
        if len(urls_list) == old_len:
            break
    pbar1.close()

    with open("urls_list.pkl", "wb") as f:
        pickle.dump(urls_list, f)

    return urls_list