from flask import Flask, jsonify, request
from flask_cors import CORS
import requests
from bs4 import BeautifulSoup
from datetime import datetime, timedelta
import json
import re
import os
from dotenv import load_dotenv

# .env dosyasından environment variable'ları yükle
load_dotenv()

app = Flask(__name__)
CORS(app)  # Flutter uygulamasından erişim için

# ==================== HESAPLAMA MODÜLLERİ ====================

@app.route('/api/hesaplama/infaz-suresi', methods=['POST'])
def hesapla_infaz_suresi():
    """İnfaz süresi hesaplama"""
    data = request.json
    ceza_suresi = data.get('ceza_suresi', 0)  # ay cinsinden
    denetimli_serbestlik = data.get('denetimli_serbestlik', False)
    
    # Basit formül (gerçek formül Ceza İnfaz Kanunu'na göre düzenlenebilir)
    if denetimli_serbestlik:
        infaz_suresi = ceza_suresi * 0.5  # %50 indirim
    else:
        infaz_suresi = ceza_suresi * 0.66  # %66 infaz
    
    return jsonify({
        'success': True,
        'ceza_suresi': ceza_suresi,
        'infaz_suresi': round(infaz_suresi, 2),
        'birim': 'ay'
    })

@app.route('/api/hesaplama/miras-sakli-pay', methods=['POST'])
def hesapla_miras_sakli_pay():
    """Miras saklı pay hesaplama (TMK'ya göre)"""
    data = request.json
    toplam_miras = float(data.get('toplam_miras', 0))
    mirasci_turu = data.get('mirasci_turu', 'cocuk')  # cocuk, es, anne_baba
    
    # TMK saklı pay oranları
    oranlar = {
        'cocuk': 0.5,  # Çocuklar için %50
        'es': 0.25,    # Eş için %25
        'anne_baba': 0.25  # Anne-baba için %25
    }
    
    oran = oranlar.get(mirasci_turu, 0.5)
    sakli_pay = toplam_miras * oran
    
    return jsonify({
        'success': True,
        'toplam_miras': toplam_miras,
        'mirasci_turu': mirasci_turu,
        'sakli_pay_orani': oran * 100,
        'sakli_pay_tutari': round(sakli_pay, 2)
    })

@app.route('/api/hesaplama/harc', methods=['POST'])
def hesapla_harc():
    """Mahkeme harç hesaplama"""
    data = request.json
    dava_degeri = float(data.get('dava_degeri', 0))
    mahkeme_turu = data.get('mahkeme_turu', 'yerel')  # yerel, istinaf, yargitay, idare, vergi, danistay
    
    # Harçlar Kanunu'na göre basitleştirilmiş hesaplama
    # Gerçek hesaplama daha karmaşık tablolara göre yapılmalı
    if mahkeme_turu == 'yerel':
        if dava_degeri <= 10000:
            harc = dava_degeri * 0.01
        elif dava_degeri <= 100000:
            harc = 100 + (dava_degeri - 10000) * 0.005
        else:
            harc = 550 + (dava_degeri - 100000) * 0.002
    elif mahkeme_turu == 'istinaf':
        harc = dava_degeri * 0.015
    elif mahkeme_turu == 'yargitay':
        harc = dava_degeri * 0.02
    else:
        harc = dava_degeri * 0.01
    
    return jsonify({
        'success': True,
        'dava_degeri': dava_degeri,
        'mahkeme_turu': mahkeme_turu,
        'harc_tutari': round(harc, 2)
    })

@app.route('/api/hesaplama/vekalet-ucreti', methods=['POST'])
def hesapla_vekalet_ucreti():
    """Avukatlık vekalet ücreti hesaplama"""
    data = request.json
    dava_degeri = float(data.get('dava_degeri', 0))
    dava_turu = data.get('dava_turu', 'hukuk')
    
    # Avukatlık Ücret Tarifesi'ne göre (basitleştirilmiş)
    if dava_degeri <= 10000:
        ucret = dava_degeri * 0.10
    elif dava_degeri <= 50000:
        ucret = 1000 + (dava_degeri - 10000) * 0.08
    elif dava_degeri <= 200000:
        ucret = 4200 + (dava_degeri - 50000) * 0.06
    else:
        ucret = 13200 + (dava_degeri - 200000) * 0.04
    
    return jsonify({
        'success': True,
        'dava_degeri': dava_degeri,
        'dava_turu': dava_turu,
        'vekalet_ucreti': round(ucret, 2)
    })

@app.route('/api/hesaplama/arabuluculuk', methods=['POST'])
def hesapla_arabuluculuk():
    """Arabuluculuk ücreti hesaplama"""
    data = request.json
    taraf_sayisi = int(data.get('taraf_sayisi', 2))
    uyusmazlik_turu = data.get('uyusmazlik_turu', 'ticari')
    
    # Arabuluculuk Yönetmeliği'ne göre
    base_ucret = 5000  # Temel ücret
    taraf_ucreti = (taraf_sayisi - 2) * 1000 if taraf_sayisi > 2 else 0
    
    toplam = base_ucret + taraf_ucreti
    
    return jsonify({
        'success': True,
        'taraf_sayisi': taraf_sayisi,
        'uyusmazlik_turu': uyusmazlik_turu,
        'arabuluculuk_ucreti': round(toplam, 2)
    })

@app.route('/api/hesaplama/makbuz', methods=['POST'])
def hesapla_makbuz():
    """Makbuz hesaplama (stopaj dahil)"""
    data = request.json
    brut_ucret = float(data.get('brut_ucret', 0))
    stopaj_orani = float(data.get('stopaj_orani', 20))  # %20
    
    stopaj_tutari = brut_ucret * (stopaj_orani / 100)
    net_ucret = brut_ucret - stopaj_tutari
    
    return jsonify({
        'success': True,
        'brut_ucret': brut_ucret,
        'stopaj_orani': stopaj_orani,
        'stopaj_tutari': round(stopaj_tutari, 2),
        'net_ucret': round(net_ucret, 2)
    })

# ==================== DÖVİZ KURLARI (TCMB API) ====================

@app.route('/api/doviz/kurlar', methods=['GET'])
def get_doviz_kurlari():
    """TCMB'den güncel döviz kurlarını çek"""
    try:
        # TCMB XML API
        url = 'https://www.tcmb.gov.tr/kurlar/today.xml'
        response = requests.get(url, timeout=10)
        
        if response.status_code == 200:
            soup = BeautifulSoup(response.content, 'xml')
            kurlar = []
            
            for currency in soup.find_all('Currency'):
                kod = currency.get('CurrencyCode', '')
                isim = currency.find('Isim')
                alis = currency.find('ForexBuying')
                satis = currency.find('ForexSelling')
                
                if isim and alis and satis:
                    kurlar.append({
                        'kod': kod,
                        'isim': isim.text,
                        'alis': float(alis.text) if alis.text else 0,
                        'satis': float(satis.text) if satis.text else 0
                    })
            
            return jsonify({
                'success': True,
                'tarih': datetime.now().strftime('%Y-%m-%d'),
                'kurlar': kurlar
            })
        else:
            return jsonify({
                'success': False,
                'error': 'TCMB API erişilemedi'
            }), 500
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/doviz/donustur', methods=['POST'])
def donustur_doviz():
    """Döviz dönüştürme"""
    data = request.json
    miktar = float(data.get('miktar', 0))
    from_currency = data.get('from', 'USD')
    to_currency = data.get('to', 'TRY')
    
    # TCMB'den kurları çek
    kurlar_response = get_doviz_kurlari()
    kurlar_data = kurlar_response.get_json()
    
    if not kurlar_data.get('success'):
        return jsonify({
            'success': False,
            'error': 'Döviz kurları alınamadı'
        }), 500
    
    # Kur bulma
    kurlar = {k['kod']: k['satis'] for k in kurlar_data['kurlar']}
    
    if from_currency == 'TRY':
        sonuc = miktar / kurlar.get(to_currency, 1)
    elif to_currency == 'TRY':
        sonuc = miktar * kurlar.get(from_currency, 1)
    else:
        # İki yabancı para arası
        sonuc = (miktar * kurlar.get(from_currency, 1)) / kurlar.get(to_currency, 1)
    
    return jsonify({
        'success': True,
        'miktar': miktar,
        'from': from_currency,
        'to': to_currency,
        'sonuc': round(sonuc, 2)
    })

# ==================== MEVZUAT ARAMA ====================

@app.route('/api/mevzuat/arama', methods=['GET'])
def arama_mevzuat():
    """Mevzuat arama"""
    query = request.args.get('q', '')
    mevzuat_turu = request.args.get('tur', 'tumu')
    
    # Mevzuat.gov.tr'den arama (örnek - gerçek API entegrasyonu gerekli)
    try:
        # Bu kısım mevzuat.gov.tr API'sine bağlanabilir veya web scraping yapılabilir
        # Şimdilik örnek veri döndürüyoruz
        sonuclar = [
            {
                'baslik': f'{query} ile ilgili mevzuat örneği 1',
                'tarih': '2024-01-15',
                'numara': '12345',
                'tur': mevzuat_turu,
                'link': f'https://mevzuat.gov.tr/mevzuat/{mevzuat_turu}/12345'
            },
            {
                'baslik': f'{query} ile ilgili mevzuat örneği 2',
                'tarih': '2024-01-20',
                'numara': '12346',
                'tur': mevzuat_turu,
                'link': f'https://mevzuat.gov.tr/mevzuat/{mevzuat_turu}/12346'
            }
        ]
        
        return jsonify({
            'success': True,
            'query': query,
            'tur': mevzuat_turu,
            'sonuclar': sonuclar,
            'toplam': len(sonuclar)
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

# ==================== YARGITAY KARAR ARAMA ====================

@app.route('/api/yargitay/arama', methods=['POST'])
def yargitay_arama():
    """Yargıtay karar arama - Gerçek veriler"""
    data = request.json
    aranacak_kelime = data.get('aranacak_kelime', '')
    birim = data.get('birim', '')
    kurul = data.get('kurul', '')
    hukuk_dairesi = data.get('hukuk_dairesi', '')
    ceza_dairesi = data.get('ceza_dairesi', '')
    esas_no = data.get('esas_no', '')
    karar_no = data.get('karar_no', '')
    karar_tarihi_baslangic = data.get('karar_tarihi_baslangic', '')
    karar_tarihi_bitis = data.get('karar_tarihi_bitis', '')
    sirala = data.get('sirala', 'esas_no')
    
    try:
        # Yargıtay web sitesine POST isteği
        yargitay_url = 'https://karararama.yargitay.gov.tr/YargitayBilgiBankasi/EsasKararArama'
        
        # Form data hazırla
        form_data = {
            'aranacakKelime': aranacak_kelime,
            'birim': birim,
            'kurul': kurul,
            'hukukDairesi': hukuk_dairesi,
            'cezaDairesi': ceza_dairesi,
            'esasNo': esas_no,
            'kararNo': karar_no,
            'kararTarihiBaslangic': karar_tarihi_baslangic,
            'kararTarihiBitis': karar_tarihi_bitis,
            'sirala': sirala,
        }
        
        # İstek gönder
        response = requests.post(
            yargitay_url,
            data=form_data,
            headers={
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            timeout=30
        )
        
        if response.status_code == 200:
            # HTML parse et
            soup = BeautifulSoup(response.content, 'html.parser')
            sonuclar = []
            
            # Karar tablosunu bul
            table = soup.find('table', class_='table') or soup.find('table')
            if table:
                rows = table.find_all('tr')[1:]  # İlk satır başlık
                for row in rows:
                    cells = row.find_all('td')
                    if len(cells) >= 4:
                        sonuc = {
                            'baslik': cells[0].get_text(strip=True) if len(cells) > 0 else '',
                            'birim': cells[1].get_text(strip=True) if len(cells) > 1 else '',
                            'esas_no': cells[2].get_text(strip=True) if len(cells) > 2 else '',
                            'karar_no': cells[3].get_text(strip=True) if len(cells) > 3 else '',
                            'tarih': cells[4].get_text(strip=True) if len(cells) > 4 else '',
                        }
                        # Karar detay linkini bul
                        link = row.find('a')
                        if link and link.get('href'):
                            sonuc['link'] = link.get('href')
                        sonuclar.append(sonuc)
            
            return jsonify({
                'success': True,
                'sonuclar': sonuclar,
                'toplam': len(sonuclar)
            })
        else:
            return jsonify({
                'success': False,
                'error': f'Yargıtay sitesi yanıt vermedi: {response.status_code}'
            }), 500
            
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/yargitay/populer', methods=['GET'])
def yargitay_populer():
    """Yargıtay popüler kararlar - En çok tıklanan 10 karar"""
    try:
        # Yargıtay ana sayfasından popüler kararları çek
        response = requests.get(
            'https://karararama.yargitay.gov.tr/',
            headers={
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            },
            timeout=30
        )
        
        if response.status_code == 200:
            soup = BeautifulSoup(response.content, 'html.parser')
            sonuclar = []
            
            # Popüler kararlar bölümünü bul (site yapısına göre güncellenebilir)
            # Örnek: popüler kararlar bir div veya tabloda olabilir
            populer_section = soup.find('div', class_='populer-kararlar') or \
                            soup.find('div', id='populer') or \
                            soup.find('table', class_='populer')
            
            if populer_section:
                items = populer_section.find_all('tr') or populer_section.find_all('div', class_='karar-item')
                for item in items[:10]:  # İlk 10
                    link = item.find('a')
                    if link:
                        baslik = link.get_text(strip=True)
                        href = link.get('href', '')
                        sonuclar.append({
                            'baslik': baslik,
                            'link': href,
                            'tarih': '',
                            'esas_no': '',
                            'karar_no': '',
                        })
            
            # Eğer popüler kararlar bulunamazsa, genel arama yap
            if not sonuclar:
                # Boş arama ile en son kararları çek
                result = yargitay_arama_internal('', '', '', '', '', '', '', '', '', 'tarih')
                if result.get('success'):
                    return jsonify(result)
                else:
                    # Son çare: örnek veri
                    sonuclar = [
                        {
                            'baslik': 'Örnek Yargıtay Kararı 1',
                            'link': 'https://karararama.yargitay.gov.tr/',
                            'tarih': '2024-01-15',
                            'esas_no': '2023/1234',
                            'karar_no': '2024/567',
                            'birim': '1. Hukuk Dairesi',
                        },
                        {
                            'baslik': 'Örnek Yargıtay Kararı 2',
                            'link': 'https://karararama.yargitay.gov.tr/',
                            'tarih': '2024-01-20',
                            'esas_no': '2023/1235',
                            'karar_no': '2024/568',
                            'birim': '2. Hukuk Dairesi',
                        }
                    ]
            
            return jsonify({
                'success': True,
                'sonuclar': sonuclar,
                'toplam': len(sonuclar)
            })
        else:
            return jsonify({
                'success': False,
                'error': f'Yargıtay sitesi yanıt vermedi: {response.status_code}'
            }), 500
            
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

def yargitay_arama_internal(aranacak_kelime, birim, kurul, hukuk_dairesi, ceza_dairesi, 
                            esas_no, karar_no, karar_tarihi_baslangic, karar_tarihi_bitis, sirala):
    """Yargıtay arama internal fonksiyon"""
    try:
        yargitay_url = 'https://karararama.yargitay.gov.tr/YargitayBilgiBankasi/EsasKararArama'
        form_data = {
            'aranacakKelime': aranacak_kelime,
            'birim': birim,
            'kurul': kurul,
            'hukukDairesi': hukuk_dairesi,
            'cezaDairesi': ceza_dairesi,
            'esasNo': esas_no,
            'kararNo': karar_no,
            'kararTarihiBaslangic': karar_tarihi_baslangic,
            'kararTarihiBitis': karar_tarihi_bitis,
            'sirala': sirala,
        }
        
        response = requests.post(yargitay_url, data=form_data, timeout=30)
        if response.status_code == 200:
            soup = BeautifulSoup(response.content, 'html.parser')
            sonuclar = []
            table = soup.find('table')
            if table:
                rows = table.find_all('tr')[1:]
                for row in rows:
                    cells = row.find_all('td')
                    if len(cells) >= 4:
                        sonuc = {
                            'baslik': cells[0].get_text(strip=True),
                            'birim': cells[1].get_text(strip=True),
                            'esas_no': cells[2].get_text(strip=True),
                            'karar_no': cells[3].get_text(strip=True),
                            'tarih': cells[4].get_text(strip=True) if len(cells) > 4 else '',
                        }
                        link = row.find('a')
                        if link:
                            sonuc['link'] = link.get('href', '')
                        sonuclar.append(sonuc)
            return {'success': True, 'sonuclar': sonuclar, 'toplam': len(sonuclar)}
        return {'success': False, 'error': 'Yanıt alınamadı'}
    except Exception as e:
        return {'success': False, 'error': str(e)}

# ==================== İÇTİHAT ARAMA ====================

@app.route('/api/ictihat/arama', methods=['GET'])
def arama_ictihat():
    """İçtihat kararları arama"""
    query = request.args.get('q', '')
    karar_turu = request.args.get('tur', 'tumu')  # yuksek_mahkeme, istinaf, yurutmeyi_durdurma, kurum
    
    # Yargıtay Karar Arama API'sine bağlanabilir
    # Şimdilik örnek veri
    sonuclar = [
        {
            'baslik': f'{query} ile ilgili karar örneği 1',
            'tarih': '2024-01-15',
            'esas_no': '2023/1234',
            'karar_no': '2024/567',
            'mahkeme': 'Yargıtay 1. Hukuk Dairesi',
            'tur': karar_turu
        },
        {
            'baslik': f'{query} ile ilgili karar örneği 2',
            'tarih': '2024-01-20',
            'esas_no': '2023/1235',
            'karar_no': '2024/568',
            'mahkeme': 'Yargıtay 2. Hukuk Dairesi',
            'tur': karar_turu
        }
    ]
    
    return jsonify({
        'success': True,
        'query': query,
        'tur': karar_turu,
        'sonuclar': sonuclar,
        'toplam': len(sonuclar)
    })

# ==================== PRATİK BİLGİLER ====================

@app.route('/api/pratik-bilgiler/genel', methods=['GET'])
def get_genel_bilgiler():
    """Genel hukuk bilgileri"""
    return jsonify({
        'success': True,
        'icerik': '''
Avukatlık mesleği, hukuki danışmanlık ve temsil hizmetleri sunan önemli bir meslektir. 
Avukatlar, müvekkillerinin haklarını korumak ve hukuki süreçlerde temsil etmekle yükümlüdür.

Avukatlık mesleğinin temel ilkeleri:
- Bağımsızlık
- Meslek sırrı
- Müvekkil menfaatini ön planda tutma
- Etik kurallara uyma
        '''
    })

@app.route('/api/pratik-bilgiler/avukatlik-kurallari', methods=['GET'])
def get_avukatlik_kurallari():
    """Avukatlık meslek kuralları"""
    return jsonify({
        'success': True,
        'icerik': '''
Avukatlık Kanunu ve Türkiye Barolar Birliği Meslek Kuralları çerçevesinde avukatların uyması gereken kurallar:

1. Meslek sırrı saklama yükümlülüğü
2. Müvekkil menfaatini koruma
3. Reklam yasağı
4. Etik kurallara uyma
5. Meslek onuruna uygun davranma
        '''
    })

@app.route('/api/pratik-bilgiler/sozluk', methods=['GET'])
def get_sozluk():
    """Hukuk terimleri sözlüğü"""
    query = request.args.get('q', '')
    
    sozluk = {
        'dava': 'Hukuki uyuşmazlıkların çözümü için başvurulan yargı yolu',
        'istinaf': 'Bölge adliye mahkemelerine yapılan başvuru',
        'temyiz': 'Yargıtay\'a yapılan başvuru',
        'icra': 'Borçların zorla tahsili',
        'mahkeme': 'Yargı organı',
        'karar': 'Mahkemenin verdiği hüküm',
        'dilekce': 'Resmi kurumlara yazılan yazı',
        'sozlesme': 'İki taraf arasındaki hukuki anlaşma'
    }
    
    if query:
        sonuc = {k: v for k, v in sozluk.items() if query.lower() in k.lower() or query.lower() in v.lower()}
    else:
        sonuc = sozluk
    
    return jsonify({
        'success': True,
        'sozluk': sonuc
    })

# ==================== YAZIM ŞABLONLARI ====================

@app.route('/api/yazim/sablonlar', methods=['GET'])
def get_yazim_sablonlari():
    """Yazım şablonları listesi"""
    return jsonify({
        'success': True,
        'sablonlar': [
            {
                'id': 1,
                'baslik': 'Genel Dilekçe Şablonu',
                'aciklama': 'Genel amaçlı dilekçe şablonu',
                'icerik': 'Dilekçe içeriği burada...'
            },
            {
                'id': 2,
                'baslik': 'İstek Dilekçesi',
                'aciklama': 'Resmi kurumlara yapılan istek dilekçesi',
                'icerik': 'İstek dilekçesi içeriği...'
            }
        ]
    })

# ==================== HUKUK ASİSTANI AI ====================

@app.route('/api/ai/dilekce-yaz', methods=['POST'])
def ai_dilekce_yaz():
    """AI ile dilekçe yazma - Sadece hukuk konularında"""
    try:
        print('=== DİLEKÇE YAZMA İSTEĞİ ALINDI ===')
        data = request.json
        print(f'Request data: {data}')
        
        dilekce_turu = data.get('dilekce_turu', 'genel')
        mahkeme = data.get('mahkeme', '')
        davaci = data.get('davaci', '')
        davali = data.get('davali', '')
        konu = data.get('konu', '')
        ek_bilgiler = data.get('ek_bilgiler', '')
        
        print(f'Dilekçe Türü: {dilekce_turu}')
        print(f'Mahkeme: {mahkeme}')
        print(f'Davacı: {davaci}')
        print(f'Davalı: {davali}')
        print(f'Konu: {konu}')
        
        # Sistem prompt'u - Dilekçe yazma için (Geliştirilmiş)
        system_prompt = """Sen Türk hukuk sistemi konusunda uzman bir hukuk asistanısın ve dilekçe yazma konusunda deneyimlisin.
Sadece hukuki dilekçeler yazarsın. Dilekçeler Türk hukuk sistemine uygun, profesyonel ve resmi dilde olmalıdır.

Dilekçe formatı ve kuralları:
1. Başlık: Dilekçe türü büyük harflerle ve ortalanmış olmalı (örn: DAVA DİLEKÇESİ, İTİRAZ DİLEKÇESİ)
2. Mahkeme/Kurum: Tam adı ve adresi yazılmalı
3. Davacı/Davalı: Tam kimlik bilgileri (ad, soyad, TC kimlik no, adres)
4. Konu: Dava konusu açık ve net belirtilmeli
5. Gerekçe: Hukuki dayanaklar (kanun maddeleri, Yargıtay kararları) belirtilmeli
6. İstek: Talep açık ve net ifade edilmeli
7. Tarih ve imza: Tarih formatı: DD.MM.YYYY

Dilekçe yazarken:
- Resmi ve saygılı bir dil kullan
- Hukuki terimleri doğru kullan
- Kanun maddelerini belirt (örn: TMK m. 2, BK m. 41)
- Yargıtay içtihatlarına atıf yap (mümkünse)
- Dilekçe tam ve eksiksiz olmalı
- Paragraflar düzenli ve okunabilir olmalı"""
        
        # Ek bilgiler varsa prompt'a ekle
        ek_bilgi_metni = f"\n\nEk Bilgiler ve Detaylar:\n{ek_bilgiler}" if ek_bilgiler else ""
        
        user_prompt = f"""Aşağıdaki bilgilere göre profesyonel ve eksiksiz bir {dilekce_turu} dilekçesi yaz:

MAHKEME/KURUM:
{mahkeme}

DAVACI:
{davaci}

DAVALI:
{davali}

KONU:
{konu}
{ek_bilgi_metni}

LÜTFEN:
1. Tam ve profesyonel bir dilekçe metni hazırla
2. Hukuki dayanakları belirt (ilgili kanun maddeleri)
3. İstekleri açık ve net ifade et
4. Resmi dilekçe formatına uygun yaz
5. Tarih formatı: DD.MM.YYYY kullan
6. Dilekçe tam ve eksiksiz olsun, sadece şablon değil gerçek bir dilekçe gibi yaz"""
        
        import os
        openai_api_key = os.getenv('OPENAI_API_KEY', '')
        
        print(f'OpenAI API Key var mı: {bool(openai_api_key)}')
        
        if openai_api_key:
            try:
                print('OpenAI API çağrısı yapılıyor...')
                from openai import OpenAI
                client = OpenAI(api_key=openai_api_key)
                
                response = client.chat.completions.create(
                    model="gpt-3.5-turbo",
                    messages=[
                        {"role": "system", "content": system_prompt},
                        {"role": "user", "content": user_prompt}
                    ],
                    temperature=0.5,  # Daha tutarlı sonuçlar için düşürüldü
                    max_tokens=2000,  # Daha uzun dilekçeler için artırıldı
                )
                
                dilekce_metni = response.choices[0].message.content
                print(f'OpenAI başarılı! Dilekçe uzunluğu: {len(dilekce_metni)} karakter')
            except Exception as e:
                print(f'OpenAI hatası: {str(e)}')
                dilekce_metni = _get_fallback_dilekce(dilekce_turu, mahkeme, davaci, davali, konu)
                print('Fallback dilekçe kullanıldı (OpenAI hatası)')
        else:
            print('OpenAI API key yok, fallback dilekçe kullanılıyor')
            dilekce_metni = _get_fallback_dilekce(dilekce_turu, mahkeme, davaci, davali, konu)
        
        print(f'Dilekçe metni hazırlandı, uzunluk: {len(dilekce_metni)} karakter')
        
        return jsonify({
            'success': True,
            'dilekce_metni': dilekce_metni,
            'dilekce_turu': dilekce_turu
        })
    except Exception as e:
        # Hata durumunda fallback dilekçe döndür
        print(f'Genel hata: {str(e)}')
        import traceback
        print(f'Traceback: {traceback.format_exc()}')
        
        fallback_dilekce = _get_fallback_dilekce(dilekce_turu, mahkeme, davaci, davali, konu)
        return jsonify({
            'success': True,  # Fallback olsa bile success döndür (kullanıcı bir şey görsün)
            'dilekce_metni': fallback_dilekce,
            'dilekce_turu': dilekce_turu,
            'warning': f'AI ile oluşturulamadı, şablon dilekçe kullanıldı: {str(e)}'
        })

@app.route('/api/ai/chat', methods=['POST'])
def ai_chat():
    """Hukuk asistanı AI chat - Sadece hukuk konularında cevap verir"""
    data = request.json
    message = data.get('message', '')
    asistan_turu = data.get('asistan_turu', 'genel')  # ictihat, mevzuat, dilekce, sozlesme, genel
    conversation_history = data.get('history', [])
    
    # Sistem prompt'u - Sadece hukuk konularında cevap vermesi için
    system_prompt = """Sen Türk hukuk sistemi konusunda uzman bir hukuk asistanısın. 
Sadece hukuk, mevzuat, içtihat, dilekçe, sözleşme ve hukuki konular hakkında bilgi verirsin.
Eğer soru hukuk dışı bir konuysa, kibarca sadece hukuk konularında yardımcı olabileceğini belirtirsin.
Türk hukuk sistemine göre doğru ve güncel bilgiler verirsin.
Yanıtların Türkçe olmalı ve profesyonel bir dil kullanmalısın."""

    # Asistan türüne göre özel prompt
    asistan_prompts = {
        'ictihat': 'Sen içtihat (yargı kararları) konusunda uzman bir asistanısın. Yargıtay, Danıştay ve diğer mahkeme kararları hakkında bilgi verirsin.',
        'mevzuat': 'Sen mevzuat (kanun, yönetmelik, kararname) konusunda uzman bir asistanısın. Türk mevzuatı hakkında bilgi verirsin.',
        'dilekce': 'Sen dilekçe hazırlama konusunda uzman bir asistanısın. Hukuki dilekçe örnekleri ve şablonları konusunda yardımcı olursun.',
        'sozlesme': 'Sen sözleşme hazırlama konusunda uzman bir asistanısın. Hukuki sözleşme türleri ve örnekleri konusunda yardımcı olursun.',
        'genel': 'Sen genel hukuk konularında yardımcı olan bir asistanısın.'
    }
    
    specific_prompt = asistan_prompts.get(asistan_turu, asistan_prompts['genel'])
    full_system_prompt = f"{system_prompt}\n\n{specific_prompt}"
    
    try:
        # OpenAI API entegrasyonu
        openai_api_key = os.getenv('OPENAI_API_KEY', '')
        
        if openai_api_key:
            # Gerçek OpenAI API çağrısı
            try:
                from openai import OpenAI
                client = OpenAI(api_key=openai_api_key)
                
                # Conversation history'yi formatla
                messages = [
                    {"role": "system", "content": full_system_prompt}
                ]
                
                # Son 10 mesajı ekle (token limiti için)
                recent_history = conversation_history[-10:] if len(conversation_history) > 10 else conversation_history
                messages.extend(recent_history)
                messages.append({"role": "user", "content": message})
                
                response = client.chat.completions.create(
                    model="gpt-3.5-turbo",
                    messages=messages,
                    temperature=0.7,
                    max_tokens=500,
                )
                
                ai_response = response.choices[0].message.content
            except Exception as e:
                # OpenAI hatası durumunda fallback
                ai_response = _get_fallback_response(message, asistan_turu)
        else:
            # API key yoksa fallback yanıt
            ai_response = _get_fallback_response(message, asistan_turu)
        
        return jsonify({
            'success': True,
            'response': ai_response,
            'asistan_turu': asistan_turu
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

def _get_fallback_dilekce(dilekce_turu, mahkeme, davaci, davali, konu):
    """Fallback dilekçe metni"""
    from datetime import datetime
    tarih = datetime.now().strftime('%d.%m.%Y')
    
    dilekce = f"""
{dilekce_turu.upper()}

{mahkeme}

DAVACI: {davaci}
DAVALI: {davali}

KONU: {konu}

{'=' * 50}

Sayın Mahkeme,

Yukarıda belirtilen konu hakkında {dilekce_turu.lower()} dilekçemizi sunuyoruz.

{konu} konusunda gerekli işlemlerin yapılmasını saygılarımla arz ederim.

{'=' * 50}

Tarih: {tarih}

Saygılarımla,
Avukat
"""
    return dilekce.strip()

def _get_fallback_response(message, asistan_turu):
    """OpenAI API key yoksa veya hata durumunda fallback yanıt"""
    message_lower = message.lower()
    
    # Hukuk dışı konuları tespit et
    non_legal_keywords = ['spor', 'futbol', 'müzik', 'film', 'yemek', 'tatil', 'seyahat', 'teknoloji', 'oyun']
    if any(keyword in message_lower for keyword in non_legal_keywords):
        return "Üzgünüm, ben sadece hukuk, mevzuat, içtihat, dilekçe ve sözleşme konularında yardımcı olabilirim. Lütfen hukuki bir soru sorun."
    
    # Dilekçe yazma isteği
    if any(word in message_lower for word in ['dilekçe yaz', 'dilekçe hazırla', 'dilekçe oluştur']):
        return "Dilekçe yazmak için lütfen 'Dilekçe Oluştur' ekranını kullanın. Orada AI ile otomatik dilekçe oluşturabilirsiniz."
    
    # Hukuk konuları
    if any(word in message_lower for word in ['merhaba', 'selam', 'hello']):
        return "Merhaba! Ben hukuk asistanınızım. Sadece hukuk, mevzuat, içtihat, dilekçe ve sözleşme konularında size yardımcı olabilirim. Nasıl yardımcı olabilirim?"
    elif any(word in message_lower for word in ['hukuk', 'kanun', 'mevzuat', 'dilekçe', 'sözleşme', 'karar', 'mahkeme', 'dava', 'yargıtay', 'danıştay']):
        return f"Hukuk konusunda sorunuzu anladım. '{message}' hakkında size yardımcı olabilirim. Ancak daha detaylı yanıtlar için OpenAI API key'i backend/app.py dosyasına eklenmelidir. Şimdilik genel bilgiler verebilirim."
    else:
        return "Üzgünüm, ben sadece hukuk, mevzuat, içtihat, dilekçe ve sözleşme konularında yardımcı olabilirim. Lütfen hukuki bir soru sorun."

# ==================== HEALTH CHECK / WAKE UP ====================

@app.route('/api/health', methods=['GET'])
def health_check():
    """Backend sağlık kontrolü ve uyandırma endpoint'i"""
    return jsonify({
        'status': 'ok',
        'message': 'Backend çalışıyor',
        'timestamp': datetime.now().isoformat()
    })

@app.route('/api/wake', methods=['GET'])
def wake_up():
    """Backend'i uyandırmak için basit endpoint (Render uyku modundan çıkarmak için)"""
    return jsonify({
        'status': 'awake',
        'message': 'Backend uyanık',
        'timestamp': datetime.now().isoformat()
    })

if __name__ == '__main__':
    # Production'da gunicorn kullanılır, bu sadece development için
    port = int(os.environ.get('PORT', 5000))
    app.run(debug=False, host='0.0.0.0', port=port)

