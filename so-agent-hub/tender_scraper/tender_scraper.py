import requests
from bs4 import BeautifulSoup
import spacy

# 抓取网页内容
def fetch_tender_page(url):
    response = requests.get(url)
    if response.status_code == 200:
        return response.text
    else:
        raise Exception(f"Failed to fetch page with status code {response.status_code}")

# 解析招标页面
def parse_tender_data(page_content):
    soup = BeautifulSoup(page_content, 'html.parser')
    tender_title = soup.find('h1', class_='tender-title').get_text()
    deadline = soup.find('span', class_='tender-deadline').get_text()
    return {
        'title': tender_title,
        'deadline': deadline
    }

# 加载spaCy模型
nlp = spacy.load('en_core_web_sm')

# 提取关键词
def extract_keywords(text):
    doc = nlp(text)
    keywords = []
    for ent in doc.ents:
        if ent.label_ in ['ORG', 'MONEY', 'DATE']:
            keywords.append((ent.text, ent.label_))
    return keywords

# 生成摘要
def generate_summary(tender_data, keywords):
    summary = f"Tender Title: {tender_data['title']}\n"
    summary += f"Deadline: {tender_data['deadline']}\n"
    summary += "Keywords:\n"
    for keyword, label in keywords:
        summary += f"- {keyword} ({label})\n"
    return summary

# 主函数
if __name__ == "__main__":
    url = input("Enter the tender URL: ")
    page_content = fetch_tender_page(url)
    tender_data = parse_tender_data(page_content)

    sample_text = "The company XYZ Corp is bidding for a contract worth  million. The deadline for submission is October 20, 2024."
    keywords = extract_keywords(sample_text)

    summary = generate_summary(tender_data, keywords)
    print(summary)

