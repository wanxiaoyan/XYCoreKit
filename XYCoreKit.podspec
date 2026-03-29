#
# Be sure to run `pod lib lint XYCoreKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XYCoreKit'
  s.version          = '0.5.0' # 版本号，后续迭代需递增，必须和后续的git tag完全一致
  s.summary          = 'iOS项目核心基础组件库，包含XYNetworking网络层、XYImageLoader图片加载组件'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
企业级iOS基础组件库，提供统一网络层封装、防OOM图片加载组件、公共工具类等能力，支持组件化按需集成
                       DESC

  # 仓库主页（填你创建的HYCoreKit代码仓库主页地址）
  s.homepage         = 'https://github.com/wanxiaoyan/XYCoreKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  # 开源协议（默认MIT，无需修改）
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  # 作者信息（修改为你的信息）
  s.author           = { 'wanxiaoyan' => 'wxy1002075730@163.com' }
  # 源码仓库地址+版本tag（填你创建的HYCoreKit代码仓库SSH/HTTPS地址）
  s.source           = { :git => 'https://github.com/wanxiaoyan/XYCoreKit.git', :tag => '0.5.0'}
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  # 系统支持配置
  s.ios.deployment_target = '10.0'
  s.requires_arc = true # 全工程默认ARC
  
  # 核心配置：子模块subspec，实现按需集成
  s.source_files = 'XYCoreKit/Classes/**/*'
  s.public_header_files = "XYCoreKit/Classes/XYCoreKit.h"
  
  # 1. 网络层模块 XYNetworking
  s.subspec 'XYNetworking' do |network|
    network.source_files = 'XYCoreKit/Classes/XYNetworking/**/*.{h,m}'
    network.public_header_files = 'XYCoreKit/Classes/XYNetworking/**/*.h'
    network.dependency 'AFNetworking' # 依赖第三方库
    network.dependency 'YYModel', '~> 1.0'
  end
  
  # 默认集成所有子模块
  s.default_subspecs = 'XYNetworking'
  
end
