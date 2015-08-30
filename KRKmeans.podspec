Pod::Spec.new do |s|
  s.name         = "KRKmeans"
  s.version      = "2.2"
  s.summary      = "KRKmeans is clustering algorithm (クラスタリング分類) that one of Machine Learning methods."
  s.description  = <<-DESC
                   KRKmeans has implemented K-Means the clustering and classification algorithm (クラスタリング分類) on Machine Learning. It could be used in data mining (データマイニング) and image compression (画像圧縮).
                   DESC
  s.homepage     = "https://github.com/Kalvar/ios-KRKmeans-Algorithm"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Kalvar Lin" => "ilovekalvar@gmail.com" }
  s.social_media_url = "https://twitter.com/ilovekalvar"
  s.source       = { :git => "https://github.com/Kalvar/ios-KRKmeans-Algorithm.git", :tag => s.version.to_s }
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.public_header_files = 'ML/*.h'
  s.source_files = 'ML/*.{h,m}'
  s.frameworks   = 'Foundation'
end 