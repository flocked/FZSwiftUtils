//
//  Bool+.swift
//
//
//  Created by Florian Zand on 02.12.24.
//

import Foundation
import RegexBuilder


public extension Bool {
    /// Formats the Boolean value with the specified format.
    func formatted<F: FormatStyle>(_ style: F) -> F.FormatOutput where F.FormatInput == Bool {
        style.format(self)
    }
    
    /// Formats the Boolean value  with the specified ``BoolFormatStyle``.
    func formatted(_ style: BoolFormatStyle = .trueFalse) -> String {
        style.format(self)
    }
        
    /**
     Creates a Boolean value from the specified localized string.
     
     Supported languages are `English`, `Spanish`, `German`, `Italian`, `French`, `Portuguese`, `Chinese`, `Japanese`, `Korean`, and `Russian`.

     - Parameters:
        - string: The localized string representation of the Boolean value.
        - locale: The locale used to interpret the string, or `nil` to match against all supported localizations.
     */
    init?(localized string: String, locale: Locale? = nil) {
        guard let value = BoolFormatStyle.Style.allCases.lazy.compactMap({ BoolFormatStyle($0, locale: locale).bool(for: string) }).first else { return nil }
        self = value
    }
    
    /// Initialize an instance by parsing the specified string with the given format style.
    init(_ value: String, format: BoolFormatStyle) throws {
        self = try format.parseStrategy.parse(value)
    }
    
    /// Initialize an instance by parsing the specified value with the given strategy.
    init<S: ParseStrategy>(_ value: S.ParseInput, strategy: S) throws where S.ParseOutput == Bool {
        self = try strategy.parse(value)
    }
}

/// A structure that converts between floating-point values and their textual representations.
public struct BoolFormatStyle: FormatStyle, Sendable, Hashable, Codable, CustomStringConvertible, ParseableFormatStyle {
    private let style: Style

    /**
     The locale of the format style.
     
     Supported languages are `English`, `Spanish`, `German`, `Italian`, `French`, `Portuguese`, `Chinese`, `Japanese`, `Korean`, and `Russian`.
     
     If the language of the specified locale isn't supported, `English` is used for formatting.

     Use the ``locale(_:)`` modifier to create a copy of this format style with a different locale.
     */
    public var locale: Locale?
    
    /**
     Modifies the format style to use the specified locale.
     
     - Parameter locale: The locale to apply to the format style.
     - Returns: A Boolean format style modified to use the provided locale.
     
     Supported languages are `English`, `Spanish`, `German`, `Italian`, `French`, `Portuguese`, `Chinese`, `Japanese`, `Korean`, and `Russian`.
     
     If the language of the specified locale isn't supported, `English` is used for formatting.
     
     Example usage:
  
     ```swift
     let formatStyle = BoolFormatStyle.yesNo
     [true, false].map { formatStyle.format($0) }
     // ["Yes", "No"]
     
     let germanStyle = formatStyle.locale(Locale(identifier: "DE"))
     [true, false].map { germanStyle.format($0) }
     // ["Ja", "Nein"]
     ```
     */
    public func locale(_ locale: Locale) -> Self {
        Self(style, locale: locale)
    }
    
    /// The Boolean format style for a "Yes" or "No" string.
    public static let yesNo = Self(.yesNo)
    /// The Boolean format style for a "True" or "False" string.
    public static let trueFalse = Self(.trueFalse)
    /// The Boolean format style for an "Enabled" or "Disabled" string.
    public static let enabledDisabled = Self(.enabledDisabled)
    /// The Boolean format style for an "On" or "Off" string.
    public static let onOff = Self(.onOff)
    /// The Boolean format style for a "Checked" or "Unchecked" string.
    public static let checkedUnchecked = Self(.checkedUnchecked)
    /// The Boolean format style for an "Active" or "Inactive" string.
    public static let activeInactive = Self(.activeInactive)
    /// The Boolean format style for an "Allowed" or "Denied" string.
    public static let allowedDenied = Self(.allowedDenied)
    /// The Boolean format style for an "Accepted" or "Rejected" string.
    public static let acceptedRejected = Self(.acceptedRejected)
    /// The Boolean format style for a "Visible" or "Hidden" string.
    public static let visibleHidden = Self(.visibleHidden)
    /// The Boolean format style for a "Valid" or "Invalid" string.
    public static let validInvalid = Self(.validInvalid)
    /// The Boolean format style for an "Open" or "Closed" string.
    public static let openClosed = Self(.openClosed)
    /// The Boolean format style for a "Start" or "Stop" string.
    public static let startStop = Self(.startStop)
    /// The Boolean format style for a "Success" or "Failure" string.
    public static let successFailure = Self(.successFailure)
    /// The Boolean format style for an "Online" or "Offline" string.
    public static let onlineOffline = Self(.onlineOffline)
    /// The Boolean format style for a "Connected" or "Disconnected" string.
    public static let connectedDisconnected = Self(.connectedDisconnected)
    /// The Boolean format style for a "Locked" or "Unlocked" string.
    public static let lockedUnlocked = Self(.lockedUnlocked)
    /// The Boolean format style for a "Selected" or "Deselected" string.
    public static let selectedDeselected = Self(.selectedDeselected)
    /// The Boolean format style for a "Running" or "Stopped" string.
    public static let runningStopped = Self(.runningStopped)
    /// The Boolean format style for a "Playing" or "Paused" string.
    public static let playingPaused = Self(.playingPaused)
    /// The Boolean format style for a "Recording" or "Stopped" string.
    public static let recordingStopped = Self(.recordingStopped)
    /// The Boolean format style for a "Pending" or "Completed" string.
    public static let pendingCompleted = Self(.pendingCompleted)
    /// The Boolean format style for an "Available" or "Unavailable" string.
    public static let availableUnavailable = Self(.availableUnavailable)
    /// The Boolean format style for a "Shown" or "Hidden" string.
    public static let shownHidden = Self(.shownHidden)
    
    fileprivate init(_ style: Style, locale: Locale? = nil) {
        self.style = style
        self.locale = locale
    }
    
    fileprivate var localizedPair: (true: String, false: String) {
        let languageCode = locale?.languageCode.flatMap { Self.supportedLanguages.contains($0) ? $0 : nil } ?? "en"
        return style.strings[languageCode]!
    }
    
    fileprivate func bool(for string: String) -> Bool? {
        let languageCodes = locale?.languageCode.map { $0 == "en" || !Self.supportedLanguages.contains($0) ? ["en"] : [$0, "en"] } ?? Self.supportedLanguages
        let strings = style.strings
        let options: String.CompareOptions = [.caseInsensitive, .widthInsensitive ]
        for key in languageCodes {
            guard let pair = strings[key] else { continue }
            let locale = Locale(identifier: key)
            if pair.true.isEqual(to: string, options: options, locale: locale) {
                return true
            } else if pair.false.isEqual(to: string, options: options, locale: locale) {
                return false
            }
        }
        return nil
    }
    
    /// Formats a Boolean value, using this style.
    public func format(_ value: Bool) -> String {
        value ? localizedPair.true : localizedPair.false
    }
    
    /// The parse strategy that this format style uses.
    public var parseStrategy: BoolParseStrategy {
        BoolParseStrategy(format: self)
    }
    
    public var description: String {
        let pair = localizedPair
        if let locale = locale?.identifier {
            return #"(true: "\#(pair.true)", false: "\#(pair.false)", locale: \#(locale))"#
        }
        return #"(true: "\#(pair.true)", false: "\#(pair.false)")"#
    }
    
    fileprivate static let supportedLanguages = ["en", "es", "de", "it", "fr", "pt", "zh", "ja", "ko", "ru"]

    /// String format style for a Boolean value.
    fileprivate enum Style: CaseIterable, Hashable, CustomStringConvertible, Sendable, Codable {
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
        /// Success / Failure
        case successFailure
        /// Online / Offline
        case onlineOffline
        /// Connected / Disconnected
        case connectedDisconnected
        /// Locked / Unlocked
        case lockedUnlocked
        /// Selected / Deselected
        case selectedDeselected
        /// Running / Stopped
        case runningStopped
        /// Playing / Paused
        case playingPaused
        /// Recording / Stopped
        case recordingStopped
        /// Pending / Completed
        case pendingCompleted
        /// Available / Unavailable
        case availableUnavailable
        /// Shown / Hidden
        case shownHidden
        
        var description: String {
            let pair = strings["en"]!
            return "\(pair.true) / \(pair.false)"
        }
        
        fileprivate var strings: [String: (true: String, false: String)] {
            Self.strings[self]!
        }
        
        fileprivate static let strings: [Self: [String: (true: String, false: String)]] = [
            .yesNo: [
                "en": ("Yes", "No"), "es": ("Sí", "No"), "fr": ("Oui", "Non"),
                "de": ("Ja", "Nein"), "it": ("Sì", "No"), "pt": ("Sim", "Não"),
                "zh": ("是", "否"), "ja": ("はい", "いいえ"), "ko": ("예", "아니요"),
                "ru": ("Да", "Нет")
            ],
            .trueFalse: [
                "en": ("True", "False"), "es": ("Verdadero", "Falso"), "fr": ("Vrai", "Faux"),
                "de": ("Wahr", "Falsch"), "it": ("Vero", "Falso"), "pt": ("Verdadeiro", "Falso"),
                "zh": ("真", "假"), "ja": ("真", "偽"), "ko": ("참", "거짓"),
                "ru": ("Истина", "Ложь")
            ],
            .enabledDisabled: [
                "en": ("Enabled", "Disabled"), "es": ("Habilitado", "Deshabilitado"), "fr": ("Activé", "Désactivé"),
                "de": ("Aktiviert", "Deaktiviert"), "it": ("Abilitato", "Disabilitato"), "pt": ("Ativado", "Desativado"),
                "zh": ("启用", "禁用"), "ja": ("有効", "無効"), "ko": ("사용 가능", "사용 불가능"),
                "ru": ("Включено", "Отключено")
            ],
            .onOff: [
                "en": ("On", "Off"), "es": ("Encendido", "Apagado"), "fr": ("Allumé", "Éteint"),
                "de": ("Ein", "Aus"), "it": ("Acceso", "Spento"), "pt": ("Ligado", "Desligado"),
                "zh": ("开", "关"), "ja": ("オン", "オフ"), "ko": ("켜짐", "꺼짐"),
                "ru": ("Включено", "Выключено")
            ],
            .checkedUnchecked: [
                "en": ("Checked", "Unchecked"), "es": ("Marcado", "Sin marcar"), "fr": ("Coché", "Non coché"),
                "de": ("Markiert", "Nicht markiert"), "it": ("Selezionato", "Non selezionato"), "pt": ("Marcado", "Desmarcado"),
                "zh": ("选中", "未选中"), "ja": ("チェック済み", "未チェック"), "ko": ("체크됨", "체크되지 않음"),
                "ru": ("Отмечено", "Не отмечено")
            ],
            .activeInactive: [
                "en": ("Active", "Inactive"), "es": ("Activo", "Inactivo"), "fr": ("Actif", "Inactif"),
                "de": ("Aktiv", "Inaktiv"), "it": ("Attivo", "Inattivo"), "pt": ("Ativo", "Inativo"),
                "zh": ("活动", "非活动"), "ja": ("アクティブ", "非アクティブ"), "ko": ("활성", "비활성"),
                "ru": ("Активный", "Неактивный")
            ],
            .allowedDenied: [
                "en": ("Allowed", "Denied"), "es": ("Permitido", "Denegado"), "fr": ("Permis", "Refusé"),
                "de": ("Erlaubt", "Verweigert"), "it": ("Consentito", "Negato"), "pt": ("Permitido", "Negado"),
                "zh": ("允许", "拒绝"), "ja": ("許可", "拒否"), "ko": ("허용됨", "거부됨"),
                "ru": ("Разрешено", "Запрещено")
            ],
            .acceptedRejected: [
                "en": ("Accepted", "Rejected"), "es": ("Aceptado", "Rechazado"), "fr": ("Accepté", "Rejeté"),
                "de": ("Akzeptiert", "Abgelehnt"), "it": ("Accettato", "Rifiutato"), "pt": ("Aceito", "Rejeitado"),
                "zh": ("接受", "拒绝"), "ja": ("承認", "拒否"), "ko": ("승인", "거절"),
                "ru": ("Принято", "Отклонено")
            ],
            .visibleHidden: [
                "en": ("Visible", "Hidden"), "es": ("Visible", "Oculto"), "fr": ("Visible", "Caché"),
                "de": ("Sichtbar", "Versteckt"), "it": ("Visibile", "Nascosto"), "pt": ("Visível", "Oculto"),
                "zh": ("可见", "隐藏"), "ja": ("表示", "非表示"), "ko": ("보임", "숨김"),
                "ru": ("Видимый", "Скрытый")
            ],
            .validInvalid: [
                "en": ("Valid", "Invalid"), "es": ("Válido", "Inválido"), "fr": ("Valide", "Invalide"),
                "de": ("Gültig", "Ungültig"), "it": ("Valido", "Non valido"), "pt": ("Válido", "Inválido"),
                "zh": ("有效", "无效"), "ja": ("有効", "無効"), "ko": ("유효", "무효"),
                "ru": ("Действительный", "Недействительный")
            ],
            .openClosed: [
                "en": ("Open", "Closed"), "es": ("Abierto", "Cerrado"), "fr": ("Ouvert", "Fermé"),
                "de": ("Offen", "Geschlossen"), "it": ("Aperto", "Chiuso"), "pt": ("Aberto", "Fechado"),
                "zh": ("开", "关"), "ja": ("開", "閉"), "ko": ("열림", "닫힘"),
                "ru": ("Открыто", "Закрыто")
            ],
            .startStop: [
                "en": ("Start", "Stop"), "es": ("Inicio", "Detener"), "fr": ("Démarrer", "Arrêter"),
                "de": ("Start", "Stop"), "it": ("Avvio", "Stop"), "pt": ("Iniciar", "Parar"),
                "zh": ("开始", "停止"), "ja": ("開始", "停止"), "ko": ("시작", "중지"),
                "ru": ("Старт", "Стоп")
            ],
            .successFailure: [
                "en": ("Success", "Failure"), "es": ("Éxito", "Fracaso"), "fr": ("Succès", "Échec"),
                "de": ("Erfolg", "Fehlschlag"), "it": ("Successo", "Fallimento"), "pt": ("Sucesso", "Falha"),
                "zh": ("成功", "失败"), "ja": ("成功", "失敗"), "ko": ("성공", "실패"),
                "ru": ("Успех", "Неудача")
            ],
            .onlineOffline: [
                "en": ("Online", "Offline"), "es": ("En línea", "Sin conexión"), "fr": ("En ligne", "Hors ligne"),
                "de": ("Online", "Offline"), "it": ("Online", "Offline"), "pt": ("Online", "Offline"),
                "zh": ("在线", "离线"), "ja": ("オンライン", "オフライン"), "ko": ("온라인", "오프라인"),
                "ru": ("В сети", "Не в сети")
            ],
            .connectedDisconnected: [
                "en": ("Connected", "Disconnected"), "es": ("Conectado", "Desconectado"), "fr": ("Connecté", "Déconnecté"),
                "de": ("Verbunden", "Getrennt"), "it": ("Connesso", "Disconnesso"), "pt": ("Conectado", "Desconectado"),
                "zh": ("已连接", "未连接"), "ja": ("接続済み", "未接続"), "ko": ("연결됨", "연결 끊김"),
                "ru": ("Подключено", "Отключено")
            ],
            .lockedUnlocked: [
                "en": ("Locked", "Unlocked"), "es": ("Bloqueado", "Desbloqueado"), "fr": ("Verrouillé", "Déverrouillé"),
                "de": ("Gesperrt", "Entsperrt"), "it": ("Bloccato", "Sbloccato"), "pt": ("Bloqueado", "Desbloqueado"),
                "zh": ("已锁定", "已解锁"), "ja": ("ロック済み", "ロック解除"), "ko": ("잠김", "잠금 해제"),
                "ru": ("Заблокировано", "Разблокировано")
            ],
            .selectedDeselected: [
                "en": ("Selected", "Deselected"), "es": ("Seleccionado", "No seleccionado"), "fr": ("Sélectionné", "Désélectionné"),
                "de": ("Ausgewählt", "Nicht ausgewählt"), "it": ("Selezionato", "Deselezionato"), "pt": ("Selecionado", "Desmarcado"),
                "zh": ("已选中", "未选中"), "ja": ("選択済み", "未選択"), "ko": ("선택됨", "선택 해제"),
                "ru": ("Выбрано", "Не выбрано")
            ],
            .runningStopped: [
                "en": ("Running", "Stopped"), "es": ("En ejecución", "Detenido"), "fr": ("En cours", "Arrêté"),
                "de": ("Läuft", "Gestoppt"), "it": ("In esecuzione", "Fermato"), "pt": ("Em execução", "Parado"),
                "zh": ("运行中", "已停止"), "ja": ("実行中", "停止"), "ko": ("실행 중", "중지됨"),
                "ru": ("Работает", "Остановлено")
            ],
            .playingPaused: [
                "en": ("Playing", "Paused"), "es": ("Reproduciendo", "Pausado"), "fr": ("Lecture", "En pause"),
                "de": ("Wiedergabe", "Pausiert"), "it": ("Riproduzione", "In pausa"), "pt": ("Reproduzindo", "Pausado"),
                "zh": ("播放中", "已暂停"), "ja": ("再生中", "一時停止"), "ko": ("재생 중", "일시 정지"),
                "ru": ("Воспроизведение", "Пауза")
            ],
            .recordingStopped: [
                "en": ("Recording", "Stopped"), "es": ("Grabando", "Detenido"), "fr": ("Enregistrement", "Arrêté"),
                "de": ("Aufnahme", "Gestoppt"), "it": ("Registrazione", "Fermata"), "pt": ("Gravando", "Parado"),
                "zh": ("录制中", "已停止"), "ja": ("録音中", "停止"), "ko": ("녹화 중", "중지됨"),
                "ru": ("Запись", "Остановлено")
            ],
            .pendingCompleted: [
                "en": ("Pending", "Completed"), "es": ("Pendiente", "Completado"), "fr": ("En attente", "Terminé"),
                "de": ("Ausstehend", "Abgeschlossen"), "it": ("In sospeso", "Completato"), "pt": ("Pendente", "Concluído"),
                "zh": ("待处理", "已完成"), "ja": ("保留中", "完了"), "ko": ("대기 중", "완료됨"),
                "ru": ("В ожидании", "Завершено")
            ],
            .availableUnavailable: [
                "en": ("Available", "Unavailable"), "es": ("Disponible", "No disponible"), "fr": ("Disponible", "Indisponible"),
                "de": ("Verfügbar", "Nicht verfügbar"), "it": ("Disponibile", "Non disponibile"), "pt": ("Disponível", "Indisponível"),
                "zh": ("可用", "不可用"), "ja": ("利用可能", "利用不可"), "ko": ("사용 가능", "사용 불가"),
                "ru": ("Доступно", "Недоступно")
            ],
            .shownHidden: [
                "en": ("Shown", "Hidden"), "es": ("Mostrado", "Oculto"), "fr": ("Affiché", "Masqué"),
                "de": ("Angezeigt", "Ausgeblendet"), "it": ("Mostrato", "Nascosto"), "pt": ("Mostrado", "Oculto"),
                "zh": ("显示", "隐藏"), "ja": ("表示", "非表示"), "ko": ("표시됨", "숨김"),
                "ru": ("Показано", "Скрыто")
            ]
        ]
    }
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
extension BoolFormatStyle: CustomConsumingRegexComponent {
    public typealias RegexOutput = Bool

    public func consuming(_ input: String, startingAt index: String.Index, in bounds: Range<String.Index>) throws -> (upperBound: String.Index, output: Bool)? {
        let pair = localizedPair
        let remaining = input[index ..< bounds.upperBound]
        if remaining.hasPrefix(pair.true) {
            return (input.index(index, offsetBy: pair.true.count), true)
        }
        if remaining.hasPrefix(pair.false) {
            return (input.index(index, offsetBy: pair.false.count), false)
        }
        return nil
    }
}

public extension BoolFormatStyle {
    /// An attributed format style based on the Boolean format style.
    var attribued: Attribted {
        Attribted(self)
    }
    
    /// A format style that converts Boolean values into attributed strings.
    struct Attribted: FormatStyle {
        private var style: BoolFormatStyle
        
        fileprivate init(_ style: BoolFormatStyle) {
            self.style = style
        }
        
        public func locale(_ locale: Locale) -> Self {
            Self(BoolFormatStyle(style.style, locale: locale))
        }
            
        /// Formats a Boolean value, using this style.
        public func format(_ value: Bool) -> AttributedString {
            AttributedString(style.format(value))
        }
    }
}

/// A parse strategy for creating boolean values from formatted strings.
public struct BoolParseStrategy: ParseStrategy, Hashable, Sendable, Codable, CustomStringConvertible {
    /// The format style this strategy uses when parsing strings.
    public var formatStyle: BoolFormatStyle

    /// Creates a parse strategy instance using the specified Boolean format style.
    public init(format: BoolFormatStyle) {
        self.formatStyle = format
    }
    
    public var description: String {
        formatStyle.description
    }

    /// Parses an boolean string in accordance with this strategy and returns the parsed value.
    public func parse(_ value: String) throws -> Bool {
        guard let value = formatStyle.bool(for: value) else {
            throw CocoaError(.formatting)
        }
       return value
    }
}

public extension FormatStyle where Self == BoolFormatStyle {
    /// A style for formatting a Boolean value as a "Yes" or "No" string.
    static var yesNo: Self {
        .yesNo
    }

    /// A style for formatting a Boolean value as a "True" or "False" string.
    static var trueFalse: Self {
        .trueFalse
    }

    /// A style for formatting a Boolean value as an "Enabled" or "Disabled" string.
    static var enabledDisabled: Self {
        .enabledDisabled
    }

    /// A style for formatting a Boolean value as an "On" or "Off" string.
    static var onOff: Self {
        .onOff
    }

    /// A style for formatting a Boolean value as a "Checked" or "Unchecked" string.
    static var checkedUnchecked: Self {
        .checkedUnchecked
    }

    /// A style for formatting a Boolean value as an "Active" or "Inactive" string.
    static var activeInactive: Self {
        .activeInactive
    }

    /// A style for formatting a Boolean value as an "Allowed" or "Denied" string.
    static var allowedDenied: Self {
        .allowedDenied
    }

    /// A style for formatting a Boolean value as an "Accepted" or "Rejected" string.
    static var acceptedRejected: Self {
        .acceptedRejected
    }

    /// A style for formatting a Boolean value as a "Visible" or "Hidden" string.
    static var visibleHidden: Self {
        .visibleHidden
    }

    /// A style for formatting a Boolean value as a "Valid" or "Invalid" string.
    static var validInvalid: Self {
        .validInvalid
    }

    /// A style for formatting a Boolean value as an "Open" or "Closed" string.
    static var openClosed: Self {
        .openClosed
    }

    /// A style for formatting a Boolean value as a "Start" or "Stop" string.
    static var startStop: Self {
        .startStop
    }

    /// A style for formatting a Boolean value as a "Success" or "Failure" string.
    static var successFailure: Self {
        .successFailure
    }

    /// A style for formatting a Boolean value as an "Online" or "Offline" string.
    static var onlineOffline: Self {
        .onlineOffline
    }

    /// A style for formatting a Boolean value as "Connected" or "Disconnected" string.
    static var connectedDisconnected: Self {
        .connectedDisconnected
    }

    /// A style for formatting a Boolean value as "Locked" or "Unlocked" string.
    static var lockedUnlocked: Self {
        .lockedUnlocked
    }

    /// A style for formatting a Boolean value as "Selected" or "Deselected" string.
    static var selectedDeselected: Self {
        .selectedDeselected
    }

    /// A style for formatting a Boolean value as "Running" or "Stopped" string.
    static var runningStopped: Self {
        .runningStopped
    }

    /// A style for formatting a Boolean value as "Playing" or "Paused" string.
    static var playingPaused: Self {
        .playingPaused
    }

    /// A style for formatting a Boolean value as "Recording" or "Stopped" string.
    static var recordingStopped: Self {
        .recordingStopped
    }

    /// A style for formatting a Boolean value as "Pending" or "Completed" string.
    static var pendingCompleted: Self {
        .pendingCompleted
    }

    /// A style for formatting a Boolean value as "Available" or "Unavailable" string.
    static var availableUnavailable: Self {
        .availableUnavailable
    }

    /// A style for formatting a Boolean value as "Shown" or "Hidden" string.
    static var shownHidden: Self {
        .shownHidden
    }
}
