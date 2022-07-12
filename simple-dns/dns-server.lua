do
    local event = require('event')
    local filesystem = require('filesystem')
    local component = require('component')
    require('lson')

    -- 名前解決サーバー.
    DNSServer =
    {
        -- DNS 辞書
        DNSdictA = {},

        -- 信号強度
        connect_power = 100,

        -- DNS 処理イベントID
        dns_event_id = 0,

        -- DNS サーバーのアドレス配信イベント ID
        address_event_id = 0,


        -- DNS サーバーを起動させる.
        startDNSService = function (self)

            if filesystem.exists('/home/dns') then
                self.DNSdict = Lson.load('/home/dns/dns.info')

            else
                -- 初回起動時に DNS 情報を保存する ディレクトリを作る
                filesystem.makeDirectory('/home/dns')

            end

            component.modem.open(53)
            component.modem.open(54)
            component.modem.setStrength(self.connect_power)

            -- DNS 処理イベント
            self.dns_event_id =
                event.listen("modem_message", function (...)
                    local _, _, remote_address, port, _, message = ...
                    if port == 53 then
                        component.modem.send(remote_address, port, self.DNSdict[message])
                    end
                end)

            -- DNS サーバーのアドレス配信
            self.address_event_id =
                event.listen("modem_message", function (...)
                    local _, self_address, remote_address, port, _, message = ...
                    if port == 54 then
                        component.modem.send(remote_address, 53, self_address)
                    end
                end)


            print('\nDNS サービスを開始しました.\n')
            print('- help -------------------')
            print('add    <address> <name>   アドレスと名前のペアで DNS 設定を追加します.\n')
            print('del    <index>            アドレスか名前で DNS 設定を削除します.\n')
            print('list                      DNS 設定一覧を表示します.\n')
            print('quit                      DNS サービスを停止します.\n')
            print('★ DNS 設定は "/home/dns/dns.info" に保存されています.\n')
            print('--------------------------')


            -- 入力受付 / ログ表示状態に移行
            while true do

                local input = io.read()
                local split = {}

                split[#split+1] = ''

                for i = 1, #input do
                    if string.sub(input, i, i) == ' ' then
                        split[#split+1] = ''
                    else
                        split[#split] = split[#split] .. string.sub(input, i, i)
                    end
                end

                local command = split[1]

                -- DNS 追加コマンド
                if command == 'add' then

                    local address = split[2]
                    local name = split[3]

                    if address ~= nil and name ~= nil then
                        self:addDNS(address, name)
                        print('[INFO]', 'DNS 設定を追加しました.\n')
                    else
                        print('[ERROR]', '入力値が不正です.\n')
                    end
                end

                -- DNS 削除コマンド
                if command == 'del' then

                    local index = split[2]

                    if index ~= nil then
                        self:delDNS(index)
                        print('[INFO]', 'DNS 設定を削除しました.\n')
                    else
                        print('[ERROR]', '入力値が不正です.\n')
                    end
                end

                -- DNS 一覧コマンド
                if command == 'list' then
                    print('■ DNS 設定一覧 ■\n')
                    for k, v in pairs(self:list()) do print(v, k) end
                    print('\n')

                end

                -- DNS 停止 コマンド
                if command == 'quit' then
                    event.cancel(self.dns_event_id)
                    event.cancel(self.address_event_id)
                    print('DNS サービスを停止しました.\n')

                    break
                end

            end

        end,


        -- DNS に名前解決情報を追加
        addDNS = function (self, address, name)

            self.DNSdict[name] = address
            self.DNSdict[address] = name
            Lson.write('/home/dns/dns.info', self.DNSdict)

        end,


        -- DNS から名前解決情報を削除
        delDNS = function (self, index)

            local pair = self.DNSdict[index]
            self.DNSdict[index] = nil
            self.DNSdict[pair] = nil
            Lson.write('/home/dns/dns.info', self.DNSdict)

        end,


        -- DNS 設定一覧を表示
        list = function (self)

            local out = {}
            for k, v in pairs(self.DNSdict) do

                -- 出来る限りアドレスが前に来るようにソートする.
                if not(out[k] == v or out[v] == k) then
                    if #k < #v then out[k] = v
                    else out[v] = k end
                end
            end
            return out
        end
    }

    DNSServer:startDNSService()

end