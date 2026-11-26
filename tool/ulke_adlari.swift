// Ülke adları (K8-5): Türkçe ve İngilizce, Unicode CLDR verisinden.
// macOS Foundation'ın yerleşik CLDR verisini kullanır; indirme gerekmez.
// Uygulamaya girmez.
//
// Kullanım (kod listesi: şehir verisindeki ülke kodları, satır başına bir):
//   swift tool/ulke_adlari.swift kodlar.txt > govde.tsv
// Çıktı satırı: kod<TAB>Türkçe ad<TAB>İngilizce ad. assets/veri/ulkeler.tsv
// bu gövdenin başına kaynak satırı eklenerek yazıldı.
import Foundation
let kodlar = try! String(contentsOfFile: CommandLine.arguments[1], encoding: .utf8).split(separator: "\n").map(String.init) + ["TR"]
let tr = Locale(identifier: "tr")
let en = Locale(identifier: "en")
for k in Set(kodlar).sorted() {
  let t = tr.localizedString(forRegionCode: k) ?? ""
  let e = en.localizedString(forRegionCode: k) ?? ""
  print("\(k)\t\(t)\t\(e)")
}
