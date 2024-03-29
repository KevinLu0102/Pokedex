# Pokédex iOS App

## 專案概述

本專案是一個使用PokéAPI v2實現 Pokédex 的 iOS 應用程式，該應用程式允許用戶瀏覽 Pokémon 列表，查看每個 Pokémon 的詳細訊息，並標記他們最喜歡的 Pokémon

## 主要功能

**Pokémon 列表**：
  - 顯示基本訊息
  - 點擊列表項將用戶帶到 Pokémon 詳情頁面
  - 當用戶滾動到列表末尾時，實現自動加載更多 Pokémon 數據
  - 實現過濾器，僅顯示用戶收藏的 Pokémon

 **Pokémon 詳情**：
  - PokémonID
  - 名稱
  - 類型
  - 圖像
  - 進化鏈，點擊進化鏈中的 Pokémon 應將用戶帶到其詳情頁面
  - 基礎統計數據
  - 圖鑑描述文本
  - 允許用戶將 Pokémon 標記/取消標記為"收藏"

## 附加功能
  - 以 List 和 Grid 兩種格式顯示 Pokémon 列表

## 開發環境
  - Xcode 15.2
  - Swift 5
  - iOS 16.0
  - CocoaPods 1.15.2
  - Ruby 3.3.0
  - MacOS 14.1

## 第三方套件
  - SDWebImage

## 安裝應用程式

要使用 Pokédex iOS 應用程式，請按照以下步驟操作：

1. 開啟Xcode，選擇上方選單 Integrate -> Clone -> 貼上URL  
2. 打開終端機，確認電腦已安裝 CocoaPods
3. Pokedex 資料夾點擊右鍵 -> 打開終端機視窗 -> pod install
4. 開啟 Pokedex.xcworkspace
5. 選擇上方 Product -> Run，即可在模擬器或連接的 iOS 設備上運行應用程式

## 設計模式

Pokédex iOS 應用程式使用到以下設計模式：

- MVVM：該應用程式遵循 MVVM 架構模式，將數據模型、UI組件和業務邏輯分離到不同層
- Singleton：APIService 和 FavoriteService 類別實現為單例，以在整個應用程式中提供用於呼叫API和管理收藏 Pokémon 的單一實例
- Delegate：應用程式使用委託模式來處理 List 和 Grid 的數據資料

## 關於程式碼

為了提高程式碼的易讀性、維護性和擴展性，在開發過程中我進行了以下內容：

- 自定義錯誤處理：在 APIService 中使用 Enum 定義了自定義的錯誤類型 NetworkError，涵蓋了各種可能的錯誤情況，提供更明確和有意義的錯誤訊息，方便錯誤處理和測試
- 收藏統一管理和解析：其他部分的程式碼不需要重複解析和讀寫的邏輯，只需要通過 FavoriteService 的方法來訪問和操作數據，減少重複的程式碼
- 遵循 API 的命名：在定義 Struct 時，將屬性的命名與 API 欄位保持一致，提高程式碼的可讀性，可以輕鬆地將程式碼與 API 文件對照
- 使用自定義類型封裝數據：通過將回傳的資料封裝在一個自定義類型中，使用這些數據時，可以透過一個統一的類型來訪問，不需要分別建立多個獨立的資料
- 可重用的自定義視圖：EmptyFavoriteView、HeaderView，當其他部分的程式碼需要顯示類似的畫面時，可以直接實例化使用
- 統一的資料接口：在 PokémonListViewController中，無論是 List 或 Grid 都使用了 viewModel 裡同一筆資料，避免重複編寫相同的數據獲取邏輯
- 數據可用性：在 PokémonDetailViewModel中的 loadPokémonDetail，提高數據的可用性，避免因單個 API 請求失敗而導致整個頁面無法顯示的情況，用戶仍然可以看到已成功獲取的資料

為了提高使用者體驗，在開發過程中我進行了以下內容：

- 加載更多顯示 Loading 動畫：當滑動到底部觸發加載更多數據時，顯示 Loading 動畫提供視覺反饋，表示應用程式正在加載數據
- 視覺化的 Stats 數據：根據每個 Pokémon 的基礎統計數據，動態計算和設置 Stats 背景的高度，提供了直觀的數據展示方式
- 未收藏畫面：當切換收藏狀態時，無資料時顯示 You haven't collected any Pokémon yet，避免使用者認為程式讀取資料失敗

## LLM輔助

在開發 Pokédex iOS 應用程式期間，我使用 Claude 來協助開發：

它幫我做了什麼：
- 請幫我產生 APIService ，提供我在開發時，能在任一處使用
- 請幫我產生 FavoriteService ，統一管理收藏的資料
- 請幫我產生網路請求失敗的 Enum ，我想要有自定義的錯誤描述
- 請幫我產生 TableView 滑動到底部時出現加載的動畫，並且包含關閉功能
- 請幫我產生一個未收藏狀態的 View ，在需要的地方可以直接實體化使用
- 請幫我產生可以依據 viewModel 的收藏狀態，來顯示星星符號的不同樣式跟顏色
- 請幫我產生 Struct ，這是我的 API 回傳 JSON 資料
- 請幫我 Code Review 有哪些地方可以改善
- 請幫我使用MARK註解分類，易於搜尋管理



