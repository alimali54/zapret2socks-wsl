# Zapret2 + SOCKS5 Proxy Kurulumu (WSL2 Ubuntu)

## 0. Zapret'i WSL İçinde Çalıştırmak Neden Gerekli Olabilir?

Windows için zaten Zapret ve Zapret2 sürümleri mevcut. Anti-cheat veya antivirüs yazılımları nedeniyle bunları kullanamadığınız durumlarda ise alternatif olarak ByeDPI'yi deneyebilirsiniz.

Ancak Windows sürümündeki Zapret/Zapret2'yi anti-cheat veya antivirüs engelleri nedeniyle kullanamıyorsanız ve ByeDPI için de çalışan bir strateji bulamadıysanız, Zapret'i WSL içinde çalıştırmak bir alternatif olabilir.

**Peki, şu an gerçekten gerekli mi?** Bence değil. Bu projeyi daha çok hobi olarak, kendime uğraş olsun diye geliştirdim. Şimdilik kullanmanız gerekmeyebilir ama ileride bir gün ihtiyaç duyulursa elimizde böyle bir alternatifin bulunması güzel olur.

Bu rehber, Windows üzerinde WSL2 ile Ubuntu kurduğunuzu varsayar.

## 1. WSL2 Ayarları

WSL ayarlarını açın ve aşağıdaki değişiklikleri yapın:

- **Ağ Modu (Networking Mode):** `Mirrored` olarak ayarlayın. Windows ile WSL arasında UDP aktarımının düzgün çalışması için bu mod gereklidir.
- **Bellek Boyutu (Memory Size):** `1024 MB` olarak ayarlayın. Böylece WSL'nin bellek tüketimini sınırlandırabilirsiniz.

## 2. Ubuntu Kurulumu

Ubuntu'yu açın ve paket listelerini güncelleyin:

```bash
sudo apt update
```

Gerekli paketleri yükleyin:

```bash
sudo apt install nftables unzip curl
```

### Kurulum dosyalarını indirme

`/opt` altında `zapret2socks` klasörünü oluşturun ve kullanıcı hesabınıza yazma izni verin:

```bash
sudo mkdir -p /opt/zapret2socks
sudo chown -R "$USER":"$USER" /opt/zapret2socks
```

Oluşturduğunuz klasöre girin:

```bash
cd /opt/zapret2socks
```

Zapret2socks paketini indirin:

```bash
curl -fSL https://github.com/alimali54/zapret2socks-wsl/releases/download/v1.0/zapret2socks-wsl.zip -o zapret.zip
```

Arşivi ayıklayın:

```bash
unzip -qo zapret.zip
```

ZIP dosyasını silin:

```bash
rm zapret.zip
```

Gerekli dosyalara çalıştırma izni verin:

```bash
chmod +x *.sh *.lua nfqws2 gost
```

## 3. Zapret2'yi Başlatma

Zapret2'yi başlatmak ve kullandığınız internet servis sağlayıcısına (ISS) uygun stratejiyi seçmek için şu komutu çalıştırın:

```bash
/opt/zapret2socks/start-zapret.sh
```

İşlem başarılı olduğunda aşağıdaki örneğe benzer bir çıktı görmelisiniz.

![Zapret2 başlatma çıktısı](https://github.com/user-attachments/assets/39ddc914-d5c5-4f6d-a796-c47d7495592f)

Zapret2'yi durdurmak için:

```bash
/opt/zapret2socks/stop-zapret.sh
```

Kurulum tamamlandığında SOCKS5 proxy adresiniz:

```text
127.0.0.1:8849
```

Artık Windows uygulamalarınızı bu proxy üzerinden bağlayabilirsiniz.

Terminali kapatabilirsiniz. Durdurmak veya tekrar çalıştırmak için yukarıda verilen komutları kullanabilirsiniz.

---

# Windows Uygulamalarını SOCKS5 Proxy'ye Bağlama

## 1. discord-drover

**Yalnızca Discord için**

GitHub: https://github.com/hdrover/discord-drover

Uygulamayı indirip çalıştırın. Proxy ayarlarını yapılandırın ve **Install** tuşuna basın.

<img width="262" height="312" alt="Ekran görüntüsü 2026-10-13 104543" src="https://github.com/user-attachments/assets/23b3d38a-f2f2-4b1a-b420-5a597c854970" />

Bundan sonra Discord, yapılandırdığınız proxy üzerinden çalışacaktır. DNS sorguları da proxy üzerinden çözümlendiğinden ayrıca DNS ayarı yapmanız gerekmez.

## 2. Proxifier

**DNS çözümlemesi: Var · UDP desteği: Yok · Ücretli**

Anasayfa: https://www.proxifier.com/

Proxifier ücretli bir uygulamadır. Zaman zaman çeşitli promosyonlarla lisans edinmek mümkün olabilir. Güncel fırsatları takip etmek için şu konuya da bakabilirsiniz:

https://techolay.net/sosyal/konu/omur-boyu-kullanimlik-proxifier.173041/

### Proxy sunucusunu ekleme

1. Proxifier'ı açın.
2. **Profile → Proxy Servers** yolunu izleyin.
3. **Add** tuşuna basın.
4. Proxy türünü SOCKS5 seçin. Adres olarak `127.0.0.1`, port olarak `8849` girin.
5. **OK** tuşuna basın ve çıkan uyarıya **Yes** diyerek devam edin.

![Proxifier proxy sunucusu ayarları](https://github.com/user-attachments/assets/a9390dab-3caf-4554-a46b-03232ad158cf)

### DNS çözümlemesini proxy üzerinden yapma

1. **Profile → Name Resolution** menüsüne girin.
2. **Detect DNS Settings Automatically** seçeneğinin işaretini kaldırın.
3. **Resolve hostnames through proxy** seçeneğini işaretleyin.

![Proxifier DNS ayarları](https://github.com/user-attachments/assets/d9b2bdd7-e5a8-4b7b-88ac-6a9382f1c468)

### Kullanım

Proxifier varsayılan yapılandırmada sistem genelindeki uygulamaların trafiğini etkileyebilir. Yalnızca belirli uygulamalarda kullanmak istiyorsanız **Profile → Proxification Rules** bölümünden uygulama bazlı kurallar oluşturabilirsiniz.

**Not:** Proxifier, UDP desteği olmamasına rağmen Discord (ses dahil) ve Roblox ile kullanılabilir. Ancak UDP gerektiren bazı uygulamalarda çalışmayabilir.

## 3. Proxifyre

**DNS çözümlemesi: Ek araç gerekir · UDP desteği: Var · Ücretsiz**

GitHub: https://github.com/wiresock/proxifyre

Proxifyre, uygulama bazında proxy yönlendirmesi yapar. Ancak DNS çözümlemesini kendisi gerçekleştirmediğinden ayrıca bir DNS çözümleyici kullanmanız gerekir.

### YogaDNS kurulumu

İndirme sayfası: https://yogadns.com/download/

YogaDNS'yi indirip kurun. Kurulumdan sonra Google DoH veya Quad9 gibi bir DNS sağlayıcısı seçerek yapılandırın ve çalıştırın.

### Proxifyre kurulumu

1. Proxifyre'ın GitHub sayfasındaki **Releases** bölümüne girin.
2. En son sürümü açın.
3. Windows için **x64** sürümünü indirin ve kurun.
4. Uygulamayı açın.

### Uygulama kurallarını yapılandırma

İlk sıradaki mevcut kurala çift tıklayın. Böyle bir kural yoksa **Add** seçeneğiyle yeni bir kural oluşturun.

Gelen pencerede **Add manually** seçeneğini kullanarak aşağıdaki uygulama adlarını ekleyin:

- `discord`
- `roblox`
- `robloxplayerbeta`
- `update.exe`

Proxy adresini `127.0.0.1`, portu `8849` olarak ayarlayın.

![Proxifyre uygulama yönlendirme ayarları](https://github.com/user-attachments/assets/2984f507-46d7-42b3-b745-8c4795e040f7)

Bu yapılandırma yalnızca eklediğiniz uygulamaları etkiler. Başka bir uygulamayı proxy üzerinden çalıştırmak isterseniz onun da kuralını ekleyebilirsiniz.

### Discord ses bağlantısı

UDP desteği sayesinde Discord'un ses bağlantısı da çalışabilir. Bunun için WSL2'nin ağ modunun **Mirrored** olması ve GOST'un SOCKS5 proxy'sinin UDP aktarımını destekleyecek şekilde çalıştırılması gerekir.

---

## Özet

| Uygulama | DNS | UDP | Kullanım |
|---|---|---|---|
| discord-drover | Proxy üzerinden | Yok | Yalnızca Discord |
| Proxifier | Proxy üzerinden | Yok | Sistem geneli veya kurallarla |
| Proxifyre + YogaDNS | YogaDNS üzerinden | Var | Uygulama bazında |

**Proxy adresi:** `127.0.0.1:8849`
