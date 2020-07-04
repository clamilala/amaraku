class ProductlistController < ApplicationController

    def index
        # 検索ワード
        @keyword = params[:keyword]
        # ソート順
        @sort = params[:sort_radio]

        # [クエリパラメータ]
        # URI.encode_www_formを使って「application/x-www-form-urlencoded」形式の文字列に変換
        # 文字列はURLエンコードされた形式に変換（半角スペースの"+"への変換等）
        #
        # （変換例）
        # 'bar baz' => 'bar+baz'
        # 'あ' => '%E3%81%82'
        #
        # hash形式でパラメタ文字列を指定し、URL形式にエンコード
        params_keyword = URI.encode_www_form({keyword: @keyword})
        params_sort = URI.encode_www_form({sort: @sort})
        # [URI]
        # URI.parseは与えられたURIからURI::Genericのサブクラスのインスタンスを返す
        # -> 今回はHTTPプロトコルなのでURI::HTTPクラスのインスタンスが返される
        #
        # オブジェクトからは以下のようにして構成要素を取得できる
        # uri.scheme => 'http'
        # uri.host   => 'mogulla3.com'
        # uri.port   => 4567
        # uri.path   => ''
        # uri.query  => 'param1=foo&param2=bar+baz&param3=%E3%81%82'
        #
        # URIを解析し、hostやportをバラバラに取得できるようにする
        uri = URI.parse("https://app.rakuten.co.jp/services/api/IchibaItem/Search/20170706?format=json&#{params_keyword}&#{params_sort}&applicationId=1056004703858248428")

        # リクエストパラメタを、インスタンス変数に格納
        @query = uri.query
    
        # # [GETリクエスト]
        # # Net::HTTP.startでHTTPセッションを開始する
        # # 既にセッションが開始している場合はIOErrorが発生
        # #
        # # 新しくHTTPセッションを開始し、結果をresponseへ格納
        # response = Net::HTTP.start(uri.host, uri.port) do |https|

        #   # httpsで通信する場合、use_sslをtrueにする
        #   #https.use_ssl = true

        #   # Net::HTTP.open_timeout=で接続時に待つ最大秒数の設定をする
        #   # タイムアウト時はTimeoutError例外が発生
        #   #
        #   # 接続時に待つ最大秒数を設定
        #   https.open_timeout = 5
    
        #   # Net::HTTP.read_timeout=で読み込み1回でブロックして良い最大秒数の設定をする
        #   # デフォルトは60秒
        #   # タイムアウト時はTimeoutError例外が発生
        #   #
        #   # 読み込み一回でブロックして良い最大秒数を設定
        #   https.read_timeout = 10
    
        #   # Net::HTTP#getでレスポンスの取得
        #   # 返り値はNet::HTTPResponseのインスタンス
        #   #
        #   # ここでWebAPIを叩いている
        #   # Net::HTTPResponseのインスタンスが返ってくる
        #   #http.get(uri.request_uri)
          
        # end
            
        # 2.httpの通信を設定する
        # 通信先のホストやポートを設定
        https = Net::HTTP.new(uri.host, uri.port)
        # httpsで通信する場合、use_sslをtrueにする
        https.use_ssl = true
        # 3.リクエストを作成する
        req = Net::HTTP::Get.new(uri.request_uri)
        # 4.リクエストを投げる/レスポンスを受け取る
        response = https.request(req)




        # 例外処理の開始
        begin
          # [レスポンス処理]
          # 2xx系以外は失敗として終了することにする
          # ※ リダイレクト対応できると良いな..
          #
          # ステータスコードに応じてレスポンスのクラスが異なる
          # 1xx系 => Net::HTTPInformation
          # 2xx系 => Net::HTTPSuccess
          # 3xx系 => Net::HTTPRedirection
          # 4xx系 => Net::HTTPClientError
          # 5xx系 => Net::HTTPServerError
          # 
          # responseの値に応じて処理を分ける
          case response
    
          # 2xx系
          #
          # 成功した場合
          when Net::HTTPSuccess
    
            # [JSONパース処理]
            # JSONオブジェクトをHashへパースする
            # JSON::ParserErrorが発生する可能性がある
            #
            # responseのbody要素をJSON形式で解釈し、hashに変換
            @result = JSON.parse(response.body)
            # 表示用の変数に結果を格納
            @itemName = @result["Items"][0]["Item"]["itemName"]
            @itemPrice = @result["Items"][0]["Item"]["itemPrice"]
            
            @itemUrl = @result["Items"][0]["Item"]["itemUrl"]
            @imageUrl = @result["Items"][0]["Item"]["mediumImageUrls"][0]["imageUrl"]
            @reviewAverage = @result["Items"][0]["Item"]["reviewAverage"]

            
            @message ="★検索成功★"
          # 3xx系
          #
          # 別のURLに飛ばされた場合
          when Net::HTTPRedirection
            # リダイレクト先のレスポンスを取得する際は
            # response['Location']でリダイレクト先のURLを取得してリトライする必要がある
            @message = "Redirection: code=#{response.code} message=#{response.message}"
            
          # その他エラー
          else
            @message = "HTTP ERROR: code=#{response.code} message=#{response.message}"
          end
    
        # [エラーハンドリング]
        # 各種処理で発生しうるエラーのハンドリング処理
        # 各エラーごとにハンドリング処理が書けるようにrescue節は小さい単位で書く
        #
        # エラー時処理
        rescue IOError => e
          @message = "e.message"
        rescue TimeoutError => e
          @message = "e.message"
        rescue JSON::ParserError => e
          @message = "e.message"
        rescue => e
          @message = "e.message"
        end
    end
end
