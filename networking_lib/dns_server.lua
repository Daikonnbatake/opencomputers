event = require('event')
filesystem = require('filesystem')
component = require('component')
require('lson')

-- 名前解決サーバー.
DNSServer =
{
    -- DNS 辞書
    DNSdict = {},

    -- 信号強度
    connect_power = 100,


    -- コールバック
    callback = function (self, remote_address, port, message)

        print('[コールバックを呼んだ]')
        component.modem.send(remote_address, port, self.DNSdict[message])
        print('[send]', remote_address, port, message)

    end,


    -- DNS サーバーを起動させる.
    startDNSService = function (self)

        if filesystem.exists('/home/dns') then
            self.DNSdict = Lson.load('/home/dns/dns.info')

        else
            -- 初回起動時に DNS 情報を保存する ディレクトリを作る
            filesystem.makeDirectory('/home/dns')

        end

        component.modem.open(53)
        component.modem.setStrength(self.connect_power)
        event.listen("modem_message", function (...)

            print('受信')
            local _, _, remote_address, port, _, message = ...
            self:callback(remote_address, port, message)

        end)

    end,


    -- DNS に名前解決情報を追加
    addDNS = function (self, address, name)

        self.DNSdict[name] = address
        self.DNSdict[address] = name
        Lson.write('/home/dns/dns.info', self.DNSdict)

    end,
}

DNSServer:startDNSService()