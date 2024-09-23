#!/bin/bash

# 创建并切换到一个项目目录
PROJECT_DIR="tender_scraper"
mkdir -p $PROJECT_DIR
cd $PROJECT_DIR

# 创建虚拟环境
echo "Creating Python virtual environment..."
python3 -m venv venv

# 激活虚拟环境
source venv/bin/activate

# 安装所需依赖
echo "Installing required dependencies..."
pip install requests beautifulsoup4 spacy

# 下载spaCy的预训练模型
echo "Downloading spaCy language model..."
python3 -m spacy download en_core_web_sm

# 创建Python脚本
echo "Generating Python script for tender scraper..."

cat <<EOL > tender_scraper.py
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

    sample_text = "The company XYZ Corp is bidding for a contract worth $5 million. The deadline for submission is October 20, 2024."
    keywords = extract_keywords(sample_text)

    summary = generate_summary(tender_data, keywords)
    print(summary)

EOL

# 提示运行脚本
echo "Setup complete. Run the script using: source venv/bin/activate && python tender_scraper.py"
