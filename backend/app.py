from flask import Flask, jsonify, request
from flask_cors import CORS
import requests
from bs4 import BeautifulSoup
from datetime import datetime, timedelta
import json
import re
import os
from dotenv import load_dotenv
import xml.etree.ElementTree as ET

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
            # XML parsing için ElementTree kullan (lxml yerine)
            root = ET.fromstring(response.content)
            kurlar = []
            
            for currency in root.findall('.//Currency'):
                kod = currency.get('CurrencyCode', '')
                isim_elem = currency.find('Isim')
                alis = currency.find('ForexBuying')
                satis = currency.find('ForexSelling')
                
                if isim_elem is not None and alis is not None and satis is not None:
                    kurlar.append({
                        'kod': kod,
                        'isim': isim_elem.text if isim_elem.text else '',
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
        # Önce Gemini, sonra OpenAI kullan (fallback)
        gemini_api_key = os.getenv('GEMINI_API_KEY', '').strip()
        openai_api_key = os.getenv('OPENAI_API_KEY', '').strip()
        
        dilekce_metni = None
        
        # Önce Gemini API ile dene
        if gemini_api_key:
            try:
                print('[DİLEKÇE] Gemini API çağrısı yapılıyor...')
                print(f'[DİLEKÇE] Gemini API Key var mı: True (Key uzunluğu: {len(gemini_api_key)} karakter)')
                import google.generativeai as genai
                
                # API sürümünü v1 olarak ayarla (v1beta yerine)
                genai.configure(api_key=gemini_api_key)
                
                # Önce mevcut modelleri listele ve doğru modeli seç
                model = None
                model_name = None
                
                try:
                    # Mevcut modelleri listele
                    available_models = genai.list_models()
                    model_names = [m.name for m in available_models if 'generateContent' in m.supported_generation_methods]
                    print(f'[DİLEKÇE] Mevcut modeller: {model_names[:10]}')  # İlk 10 modeli göster
                    
                    # Model adlarını temizle (models/ prefix'ini kaldır)
                    clean_model_names = []
                    for name in model_names:
                        if '/' in name:
                            clean_name = name.split('/')[-1]  # models/gemini-1.5-pro -> gemini-1.5-pro
                        else:
                            clean_name = name
                        clean_model_names.append(clean_name)
                    
                    # Öncelik sırasına göre model seç (en güncelden eskiye)
                    priority_models = [
                        'gemini-1.5-pro',
                        'gemini-1.5-flash',
                        'gemini-pro',
                        'gemini-1.0-pro'
                    ]
                    
                    for priority_model in priority_models:
                        if priority_model in clean_model_names:
                            model = genai.GenerativeModel(priority_model)
                            model_name = priority_model
                            print(f'[DİLEKÇE] Model seçildi: {priority_model}')
                            break
                    
                    # Eğer öncelikli modeller bulunamazsa, ilk uygun modeli kullan
                    if model is None and clean_model_names:
                        first_model = clean_model_names[0]
                        model = genai.GenerativeModel(first_model)
                        model_name = first_model
                        print(f'[DİLEKÇE] Model seçildi: {first_model} (varsayılan)')
                        
                except Exception as list_error:
                    print(f'[DİLEKÇE] Model listesi alınamadı: {str(list_error)[:200]}')
                    # Model listesi alınamazsa, doğrudan desteklenen modelleri dene
                    fallback_models = ['gemini-1.5-pro', 'gemini-1.5-flash', 'gemini-pro']
                    for fallback_model in fallback_models:
                        try:
                            model = genai.GenerativeModel(fallback_model)
                            model_name = fallback_model
                            print(f'[DİLEKÇE] Model seçildi: {fallback_model} (fallback)')
                            break
                        except Exception as e:
                            print(f'[DİLEKÇE] {fallback_model} deneniyor... başarısız: {str(e)[:100]}')
                            continue
                
                if model is None:
                    raise Exception('Hiçbir Gemini modeli çalışmıyor! Lütfen Render Environment Variables\'da GEMINI_API_KEY\'i kontrol edin.')
                
                prompt = f"""{system_prompt}

{user_prompt}"""
                
                response = model.generate_content(
                    prompt,
                    generation_config=genai.types.GenerationConfig(
                        temperature=0.5,
                        max_output_tokens=2000,
                    )
                )
                dilekce_metni = response.text.strip()
                print(f'Gemini başarılı! Dilekçe uzunluğu: {len(dilekce_metni)} karakter')
            except Exception as e:
                print(f'Gemini hatası: {str(e)}')
                import traceback
                print(f'Gemini traceback: {traceback.format_exc()}')
                dilekce_metni = None
        
        # Gemini başarısız olduysa OpenAI'ye geç
        if not dilekce_metni:
            if openai_api_key:
                try:
                    print('[DİLEKÇE] OpenAI API çağrısı yapılıyor (Gemini fallback)...')
                    print(f'[DİLEKÇE] OpenAI API Key var mı: True (Key uzunluğu: {len(openai_api_key)} karakter)')
                    from openai import OpenAI
                    client = OpenAI(api_key=openai_api_key)
                    
                    # OpenAI için prompt hazırla
                    openai_prompt = f"""{system_prompt}

{user_prompt}"""
                    
                    # OpenAI API çağrısı
                    response = client.chat.completions.create(
                        model="gpt-3.5-turbo",
                        messages=[
                            {"role": "system", "content": system_prompt},
                            {"role": "user", "content": user_prompt}
                        ],
                        temperature=0.5,
                        max_tokens=2000
                    )
                    dilekce_metni = response.choices[0].message.content.strip()
                    print(f'[DİLEKÇE] OpenAI başarılı! Dilekçe uzunluğu: {len(dilekce_metni)} karakter')
                except Exception as e:
                    print(f'[DİLEKÇE] OpenAI hatası: {str(e)}')
                    import traceback
                    print(f'[DİLEKÇE] OpenAI traceback: {traceback.format_exc()}')
                    dilekce_metni = None
        
        # Hem Gemini hem OpenAI başarısız olduysa fallback dilekçe
        if not dilekce_metni:
            if not gemini_api_key and not openai_api_key:
                print('[DİLEKÇE] Hiçbir API key yok, fallback dilekçe kullanılıyor')
            else:
                print('[DİLEKÇE] Tüm AI servisleri başarısız, fallback dilekçe kullanılıyor')
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
        # Önce Gemini, sonra OpenAI kullan (fallback)
        gemini_api_key = os.getenv('GEMINI_API_KEY', '').strip()
        openai_api_key = os.getenv('OPENAI_API_KEY', '').strip()
        
        ai_response = None
        
        # Önce Gemini API ile dene
        if gemini_api_key:
            try:
                print('[AI CHAT] Gemini API çağrısı yapılıyor...')
                print(f'[AI CHAT] Gemini API Key var mı: True (Key uzunluğu: {len(gemini_api_key)} karakter)')
                import google.generativeai as genai
                
                # API sürümünü v1 olarak ayarla (v1beta yerine)
                genai.configure(api_key=gemini_api_key)
                
                # Önce mevcut modelleri listele ve doğru modeli seç
                model = None
                model_name = None
                
                try:
                    # Mevcut modelleri listele
                    available_models = genai.list_models()
                    model_names = [m.name for m in available_models if 'generateContent' in m.supported_generation_methods]
                    print(f'[AI CHAT] Mevcut modeller: {model_names[:10]}')  # İlk 10 modeli göster
                    
                    # Model adlarını temizle (models/ prefix'ini kaldır)
                    clean_model_names = []
                    for name in model_names:
                        if '/' in name:
                            clean_name = name.split('/')[-1]  # models/gemini-1.5-pro -> gemini-1.5-pro
                        else:
                            clean_name = name
                        clean_model_names.append(clean_name)
                    
                    # Öncelik sırasına göre model seç (en güncelden eskiye)
                    priority_models = [
                        'gemini-1.5-pro',
                        'gemini-1.5-flash',
                        'gemini-pro',
                        'gemini-1.0-pro'
                    ]
                    
                    for priority_model in priority_models:
                        if priority_model in clean_model_names:
                            model = genai.GenerativeModel(priority_model)
                            model_name = priority_model
                            print(f'[AI CHAT] Model seçildi: {priority_model}')
                            break
                    
                    # Eğer öncelikli modeller bulunamazsa, ilk uygun modeli kullan
                    if model is None and clean_model_names:
                        first_model = clean_model_names[0]
                        model = genai.GenerativeModel(first_model)
                        model_name = first_model
                        print(f'[AI CHAT] Model seçildi: {first_model} (varsayılan)')
                        
                except Exception as list_error:
                    print(f'[AI CHAT] Model listesi alınamadı: {str(list_error)[:200]}')
                    # Model listesi alınamazsa, doğrudan desteklenen modelleri dene
                    fallback_models = ['gemini-1.5-pro', 'gemini-1.5-flash', 'gemini-pro']
                    for fallback_model in fallback_models:
                        try:
                            model = genai.GenerativeModel(fallback_model)
                            model_name = fallback_model
                            print(f'[AI CHAT] Model seçildi: {fallback_model} (fallback)')
                            break
                        except Exception as e:
                            print(f'[AI CHAT] {fallback_model} deneniyor... başarısız: {str(e)[:100]}')
                            continue
                
                if model is None:
                    raise Exception('Hiçbir Gemini modeli çalışmıyor! Lütfen Render Environment Variables\'da GEMINI_API_KEY\'i kontrol edin.')
                
                # Conversation history'yi formatla - Gemini için optimize edilmiş format
                conversation_text = f"""Sistem Talimatları:
{full_system_prompt}

Konuşma Geçmişi:
"""
                
                # Son 10 mesajı ekle
                recent_history = conversation_history[-10:] if len(conversation_history) > 10 else conversation_history
                for msg in recent_history:
                    role = msg.get('role', 'user')
                    content = msg.get('content', '')
                    if role == 'user':
                        conversation_text += f"Kullanıcı: {content}\n"
                    else:
                        conversation_text += f"Asistan: {content}\n"
                
                conversation_text += f"\nŞimdi kullanıcı soruyor: {message}\n\nLütfen yukarıdaki sistem talimatlarına göre Türk hukuk sistemi konusunda profesyonel bir yanıt ver:"
                
                # Gemini API çağrısı
                response = model.generate_content(
                    conversation_text,
                    generation_config=genai.types.GenerationConfig(
                        temperature=0.7,
                        max_output_tokens=1000,
                    )
                )
                ai_response = response.text.strip()
                print(f'[AI CHAT] Gemini başarılı! Yanıt uzunluğu: {len(ai_response)} karakter')
            except Exception as e:
                print(f'[AI CHAT] Gemini hatası: {str(e)}')
                import traceback
                print(f'[AI CHAT] Gemini traceback: {traceback.format_exc()}')
                ai_response = None
        
        # Gemini başarısız olduysa OpenAI'ye geç
        if not ai_response:
            if openai_api_key:
                try:
                    print('[AI CHAT] OpenAI API çağrısı yapılıyor (Gemini fallback)...')
                    print(f'[AI CHAT] OpenAI API Key var mı: True (Key uzunluğu: {len(openai_api_key)} karakter)')
                    from openai import OpenAI
                    client = OpenAI(api_key=openai_api_key)
                    
                    # Conversation history'yi OpenAI formatına çevir
                    messages = [{"role": "system", "content": full_system_prompt}]
                    for msg in conversation_history[-10:]:  # Son 10 mesaj
                        role = msg.get('role', 'user')
                        content = msg.get('content', '')
                        if role == 'user':
                            messages.append({"role": "user", "content": content})
                        else:
                            messages.append({"role": "assistant", "content": content})
                    messages.append({"role": "user", "content": message})
                    
                    # OpenAI API çağrısı
                    response = client.chat.completions.create(
                        model="gpt-3.5-turbo",
                        messages=messages,
                        temperature=0.7,
                        max_tokens=1000
                    )
                    ai_response = response.choices[0].message.content.strip()
                    print(f'[AI CHAT] OpenAI başarılı! Yanıt uzunluğu: {len(ai_response)} karakter')
                except Exception as e:
                    print(f'[AI CHAT] OpenAI hatası: {str(e)}')
                    import traceback
                    print(f'[AI CHAT] OpenAI traceback: {traceback.format_exc()}')
                    ai_response = None
        
        # Hem Gemini hem OpenAI başarısız olduysa fallback yanıt
        if not ai_response:
            if not gemini_api_key and not openai_api_key:
                print('[AI CHAT] Hiçbir API key yok, fallback yanıt kullanılıyor')
            else:
                print('[AI CHAT] Tüm AI servisleri başarısız, fallback yanıt kullanılıyor')
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
        # Genel hukuk bilgisi ver (API key olmasa bile)
        return f"Hukuk konusunda sorunuzu anladım. '{message}' hakkında genel bilgiler verebilirim. Daha detaylı yanıtlar için lütfen Render dashboard'da OPENAI_API_KEY environment variable'ını kontrol edin."
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

