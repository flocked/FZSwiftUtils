//
//  Bool+.swift
//
//
//  Created by Florian Zand on 02.12.24.
//

import Foundation

extension Bool {
    /**
     Returns a localized string representation of the Boolean value for the specified language, or English if no translation for the language could be found.
     
     - Parameters:
        - representation: The string representation style.
        - locale: The language.
     */
    public func localizedString(for representation: StringRepresentation = .trueFalse, locale: Locale = .current) -> String {
        let languageCode = locale.languageCode ?? "en"
        let localizedPair = representation.strings[languageCode] ?? representation.strings["en"]!
        return self ? localizedPair.true : localizedPair.false
    }
    
    /// Creates a Boolean value from a localized string, or `nil` if the string doesn't represent a Boolean value.
    public init?(localizedString: String) {
        guard let value = Bool.fromString(localizedString) else { return nil }
        self = value
    }
    
    /// String representation style for a Boolean value.
    public enum StringRepresentation: CaseIterable {
        /// Yes / No
        case yesNo
        /// True / False
        case trueFalse
        /// Enabled / Disabled
        case enabledDisabled
        /// On / Off
        case onOff
        /// Checked / Unchecked
        case checkedUnchecked
        /// Active / Inactive
        case activeInactive
        /// Allowed / Denied
        case allowedDenied
        /// Accepted / Rejected
        case acceptedRejected
        /// Visible / Hidden
        case visibleHidden
        /// Valid / Invalid
        case validInvalid
        /// Open / Closed
        case openClosed
        /// Start / Stop
        case startStop
        
        var strings: [String: (true: String, false: String)] {
            switch self {
            case .yesNo:
                return [
                    "en": ("Yes", "No"), "es": ("Sí", "No"), "fr": ("Oui", "Non"),
                    "de": ("Ja", "Nein"), "it": ("Sì", "No"), "pt": ("Sim", "Não"),
                    "zh": ("是", "否"), "ja": ("はい", "いいえ"), "ko": ("예", "아니요"),
                    "ru": ("Да", "Нет")
                ]
            case .trueFalse:
                return [
                    "en": ("True", "False"), "es": ("Verdadero", "Falso"), "fr": ("Vrai", "Faux"),
                    "de": ("Wahr", "Falsch"), "it": ("Vero", "Falso"), "pt": ("Verdadeiro", "Falso"),
                    "zh": ("真", "假"), "ja": ("真", "偽"), "ko": ("참", "거짓"), "ru": ("Истина", "Ложь")
                ]
            case .enabledDisabled:
                return [
                    "en": ("Enabled", "Disabled"), "es": ("Habilitado", "Deshabilitado"), "fr": ("Activé", "Désactivé"),
                    "de": ("Aktiviert", "Deaktiviert"), "it": ("Abilitato", "Disabilitato"), "pt": ("Ativado", "Desativado"),
                    "zh": ("启用", "禁用"), "ja": ("有効", "無効"), "ko": ("사용 가능", "사용 불가능"), "ru": ("Включено", "Отключено")
                ]
            case .onOff:
                return [
                    "en": ("On", "Off"), "es": ("Encendido", "Apagado"), "fr": ("Allumé", "Éteint"),
                    "de": ("Ein", "Aus"), "it": ("Acceso", "Spento"), "pt": ("Ligado", "Desligado"),
                    "zh": ("开", "关"), "ja": ("オン", "オフ"), "ko": ("켜짐", "꺼짐"), "ru": ("Включено", "Выключено")
                ]
            case .checkedUnchecked:
                return [
                    "en": ("Checked", "Unchecked"), "es": ("Marcado", "Sin marcar"), "fr": ("Coché", "Non coché"),
                    "de": ("Markiert", "Nicht markiert"), "it": ("Selezionato", "Non selezionato"), "pt": ("Marcado", "Desmarcado"),
                    "zh": ("选中", "未选中"), "ja": ("チェック済み", "未チェック"), "ko": ("체크됨", "체크되지 않음"), "ru": ("Отмечено", "Не отмечено")
                ]
            case .activeInactive:
                return [
                    "en": ("Active", "Inactive"), "es": ("Activo", "Inactivo"), "fr": ("Actif", "Inactif"),
                    "de": ("Aktiv", "Inaktiv"), "it": ("Attivo", "Inattivo"), "pt": ("Ativo", "Inativo"),
                    "zh": ("活动", "非活动"), "ja": ("アクティブ", "非アクティブ"), "ko": ("활성", "비활성"), "ru": ("Активный", "Неактивный")
                ]
            case .allowedDenied:
                return [
                    "en": ("Allowed", "Denied"), "es": ("Permitido", "Denegado"), "fr": ("Permis", "Refusé"),
                    "de": ("Erlaubt", "Verweigert"), "it": ("Consentito", "Negato"), "pt": ("Permitido", "Negado"),
                    "zh": ("允许", "拒绝"), "ja": ("許可", "拒否"), "ko": ("허용됨", "거부됨"), "ru": ("Разрешено", "Запрещено")
                ]
            case .acceptedRejected:
                return [
                    "en": ("Accepted", "Rejected"), "es": ("Aceptado", "Rechazado"), "fr": ("Accepté", "Rejeté"),
                    "de": ("Akzeptiert", "Abgelehnt"), "it": ("Accettato", "Rifiutato"), "pt": ("Aceito", "Rejeitado"),
                    "zh": ("接受", "拒绝"), "ja": ("承認", "拒否"), "ko": ("승인", "거절"), "ru": ("Принято", "Отклонено")
                ]
            case .visibleHidden:
                return [
                    "en": ("Visible", "Hidden"), "es": ("Visible", "Oculto"), "fr": ("Visible", "Caché"),
                    "de": ("Sichtbar", "Versteckt"), "it": ("Visibile", "Nascosto"), "pt": ("Visível", "Oculto"),
                    "zh": ("可见", "隐藏"), "ja": ("表示", "非表示"), "ko": ("보임", "숨김"), "ru": ("Видимый", "Скрытый")
                ]
            case .validInvalid:
                return [
                    "en": ("Valid", "Invalid"), "es": ("Válido", "Inválido"), "fr": ("Valide", "Invalide"),
                    "de": ("Gültig", "Ungültig"), "it": ("Valido", "Non valido"), "pt": ("Válido", "Inválido"),
                    "zh": ("有效", "无效"), "ja": ("有効", "無効"), "ko": ("유효", "무효"), "ru": ("Действительный", "Недействительный")
                ]
            case .openClosed:
                return [
                    "en": ("Open", "Closed"), "es": ("Abierto", "Cerrado"), "fr": ("Ouvert", "Fermé"),
                    "de": ("Offen", "Geschlossen"), "it": ("Aperto", "Chiuso"), "pt": ("Aberto", "Fechado"),
                    "zh": ("开", "关"), "ja": ("開", "閉"), "ko": ("열림", "닫힘"), "ru": ("Открыто", "Закрыто")
                ]
            case .startStop:
                return [
                    "en": ("Start", "Stop"), "es": ("Inicio", "Detener"), "fr": ("Démarrer", "Arrêter"),
                    "de": ("Start", "Stop"), "it": ("Avvio", "Stop"), "pt": ("Iniciar", "Parar"),
                    "zh": ("开始", "停止"), "ja": ("開始", "停止"), "ko": ("시작", "중지"), "ru": ("Старт", "Стоп")
                ]
            }
        }
    }
    
    static func fromString(_ string: String) -> Bool? {
        for key in ["en", "es", "de", "it", "fr", "pt", "zh", "ja", "ko", "ru"] {
            for representation in StringRepresentation.allCases {
                if representation.strings[key]?.false == string {
                    return false
                } else if representation.strings[key]?.true == string {
                    return true
                }
            }
        }
        return nil
    }
}

