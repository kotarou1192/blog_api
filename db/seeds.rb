# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# グルメカテゴリ
foods_category = %w[グルメ総合 食べ歩き スイーツ 料理 お酒 外食 レシピ]
cat = Category.create(name: 'グルメ')
foods_category.each do |name|
  cat.sub_categories.create(name: name)
end

# 暮らしカテゴリ
life_style_category = %w[雑貨 暮らしのアイデア インテリア 節約 DIY 掃除 介護 福祉 子育て 地域情報]
cat = Category.create(name: '暮らし')
life_style_category.each do |name|
  cat.sub_categories.create(name: name)
end

# ペットカテゴリ
pet_category = %w[ペット総合 犬 猫 淡水魚 熱帯魚 海水魚 両生類 爬虫類 小動物 昆虫 鳥類 インコ オウム ウサギ ペットショップ ハムスター ニッチなペット]
cat = Category.create(name: 'ペット')
pet_category.each do |name|
  cat.sub_categories.create(name: name)
end

# 旅行カテゴリ
travel_category = %w[旅行総合 国内旅行 海外旅行 レジャー 温泉 留学 登山 アウトドア]
cat = Category.create(name: '旅行')
travel_category.each do |name|
  cat.sub_categories.create(name: name)
end

# 日記
diary_category = %w[日記 小学生 中学生 高校生 大学生 社会人 シニア OL サラリーマン 闘病記 独身 無職]
cat = Category.create(name: '日記')
diary_category.each do |name|
  cat.sub_categories.create(name: name)
end

# ニュース
news_category = %w[ニュース総合 スポーツニュース 芸能ニュース 映画ニュース 海外ニュース 国内ニュース 国際ニュース]
cat = Category.create(name: 'ニュース')
news_category.each do |name|
  cat.sub_categories.create(name: name)
end

# スポーツ
sports_category = %w[スポーツ総合 野球 サッカー ラグビー 空手 テニス カバディ 釣り ランニング ゴルフ 格闘技 競馬 ボウリング 剣道 柔道 水泳 卓球 ボクシング フィギュアスケート バレーボール]
cat = Category.create(name: 'スポーツ')
sports_category.each do |name|
  cat.sub_categories.create(name: name)
end

# ビジネス
business_category = %w[ビジネス総合 経済 製造業 漁業 農業 為替 アルバイト 転職 就活 起業 キャリア]
cat = Category.create(name: 'ビジネス')
business_category.each do |name|
  cat.sub_categories.create(name: name)
end

# 趣味
hobby_category = %w[趣味総合 車 バイク コスプレ 創作 絵画 アート 書道 写真 フィギュア プラモ 小説 オカルト 雑貨 ラジコン 占い ラノベ おもちゃ 雑学]
cat = Category.create(name: '趣味')
hobby_category.each do |name|
  cat.sub_categories.create(name: name)
end

# 音楽
music_category = %w[音楽総合 邦楽 洋楽 クラシック オーケストラ ジャズ ロック R&B 演歌 演奏 楽器 ピアノ ベース ギター ドラム ボーカル 楽曲レビュー バンド]
cat = Category.create(name: '音楽')
music_category.each do |name|
  cat.sub_categories.create(name: name)
end

# 書籍
book_category = %w[書籍総合 小説 技術書 読書感想 雑誌 古本]
cat = Category.create(name: '書籍')
book_category.each do |name|
  cat.sub_categories.create(name: name)
end

# マンガ・アニメ
anime_category = %w[漫画総合 アニメ総合 声優 コミック グッズ 漫画感想 アニメ感想 同人誌 ウェブ作品]
cat = Category.create(name: '漫画・アニメ')
anime_category.each do |name|
  cat.sub_categories.create(name: name)
end

# ドラマ・映画
cinema_category = %w[映画総合 ドラマ総合 洋画 邦画 SF ドラマ感想 映画感想 俳優]
cat = Category.create(name: 'ドラマ・映画')
cinema_category.each do |name|
  cat.sub_categories.create(name: name)
end

# ゲーム
game_category = %w[ゲーム総合 家庭用ゲーム インディーズゲーム PCゲーム オンラインゲーム ボードゲーム TRPG ゲーム配信 FPS ゲームレビュー]
cat = Category.create(name: 'ゲーム')
game_category.each do |name|
  cat.sub_categories.create(name: name)
end

# 勉強
study_category = %w[受験 資格学習 外国語学習]
cat = Category.create(name: '勉強')
study_category.each do |name|
  cat.sub_categories.create(name: name)
end

# ヘルス・ビューティー
health_category = %w[健康総合 美容総合 ダイエット ファッション コスメ 運動 サプリ メンタルヘルス]
cat = Category.create(name: 'ヘルス・ビューティー')
health_category.each do |name|
  cat.sub_categories.create(name: name)
end

# IT・家電
tech_category = %w[家電総合 スマホ タブレット PC ウェアラブル オーディオ ソフトウェア セキュリティ プログラミング Webデザイン]
cat = Category.create(name: 'IT・家電')
tech_category.each do |name|
  cat.sub_categories.create(name: name)
end

# 学問・科学
science_category = %w[学問総合 科学総合 歴史 哲学 宗教 生物学 化学 地学 工学 技術 経済学 政治学 法律]
cat = Category.create(name: '学問・科学')
science_category.each do |name|
  cat.sub_categories.create(name: name)
end

# そのた
other_category = %w[まとめ その他]
cat = Category.create(name: 'その他')
other_category.each do |name|
  cat.sub_categories.create(name: name)
end
