import UIKit

final class ConsoleView: UIView {

    private var allLines: [String] = []
    private var currentFilter: String = ""

    private let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.placeholder = "Search logs"
        bar.barStyle = .black
        bar.searchBarStyle = .minimal
        return bar
    }()

    private let textView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isEditable = false
        tv.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        tv.textColor = UIColor(red: 0.0, green: 0.9, blue: 0.4, alpha: 1.0)
        tv.font = UIFont.monospacedSystemFont(ofSize: 11, weight: .regular)
        tv.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        return tv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setup() {
        backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)

        addSubview(searchBar)
        addSubview(textView)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: trailingAnchor),

            textView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        searchBar.delegate = self

        allLines = LogManager.shared.logs
        render()

        NotificationCenter.default.addObserver(self, selector: #selector(handleNewLog(_:)), name: .newLogMessage, object: nil)
    }

    @objc private func handleNewLog(_ notification: Notification) {
        guard let entry = notification.object as? String else { return }
        allLines.append(entry)
        render()
    }

    private func render() {
        let visibleLines: [String]
        if currentFilter.isEmpty {
            visibleLines = allLines
        } else {
            visibleLines = allLines.filter { $0.lowercased().contains(currentFilter) }
        }
        textView.text = visibleLines.joined(separator: "\n")
        guard !textView.text.isEmpty else { return }
        let bottom = NSRange(location: textView.text.count - 1, length: 1)
        textView.scrollRangeToVisible(bottom)
    }
}

extension ConsoleView: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentFilter = searchText.lowercased()
        render()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        currentFilter = ""
        render()
        searchBar.resignFirstResponder()
    }
}
