# 注音符號學習單產生器

這是一個為幼兒設計的注音符號 A4 學習單產生器。基於 Vue 3 和 Tailwind CSS 開發，採用單一網頁架構，無須複雜的安裝與編譯，下載後直接點擊 `index.html` 即可在瀏覽器中開啟與列印。

## 功能特色
- **完整的 37 個注音符號資料庫**，每個注音皆配有 3 個精選詞彙、注音標註與可愛的表情符號 (Emoji) 圖像。
- **隨機氣泡遊戲區**：每次切換注音時，系統會自動在右側產生隨機的注音氣泡，供小朋友練習尋找與塗色。
- **自適應列印樣式 (Print Style)**：點擊「列印本頁 A4」會自動隱藏側邊欄，將右側學習單完美適配於 A4 紙張大小進行列印或輸出為 PDF。
- **純靜態網頁架構**：完全無需 Node.js 環境，適合上傳至 Git 平台 (如 GitHub Pages、GitLab Pages) 提供線上免安裝使用。

## 本機開啟與使用
1. 直接點擊 `index.html`，即可使用瀏覽器開啟此應用。
2. 點擊左側注音符號，右側即會即時切換內容。
3. 點擊「列印本頁 A4」或在瀏覽器按 `Ctrl + P` / `Cmd + P` 即可將學習單列印成實體紙張或儲存成 PDF。

## 部署至 GitHub Pages
如果您想要將此網頁部署至 GitHub Pages，請按照以下步驟操作：

1. 在 GitHub 上建立一個新的公開儲存庫 (Repository)。
2. 將此專案推送 (Push) 至您的 GitHub 儲存庫：
   ```bash
   git remote add origin <您的_GITHUB_儲存庫_網址>
   git branch -M main
   git push -u origin main
   ```
3. 在 GitHub 專案頁面中：
   - 點擊 **Settings** (設定) -> **Pages**。
   - 在 **Build and deployment** 下的 **Source** 選擇 `Deploy from a branch`。
   - 在 **Branch** 選擇 `main` 分支並選取 `/ (root)` 資料夾，點擊 **Save**。
4. 等待幾分鐘後，您的專案將會發佈在 `https://<您的_GITHUB_帳號>.github.io/<您的_儲存庫_名稱>/`！
