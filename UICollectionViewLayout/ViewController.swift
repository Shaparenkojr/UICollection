//
//  ViewController.swift
//  UICollectionViewLayout
//
//  Created by Тарас Шапаренко on 08.11.2024.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var collectionView: UICollectionView = {
        let layout = CollectionViewLayout()
        layout.data = collectionData
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.identifier)
        return collectionView
    }()
    
    private let collectionData: Data = Data(alignment: .center,
                                            elements: [[.small, .small, .normal, .small],
                                                       [.normal, .small, .normal],
                                                       [.small, .normal, .small],
                                                       [.small, .normal],
                                                       [.small, .small, .small, .small],
                                                       [.small],
                                                       [.normal, .normal],
                                                       [.normal]])

    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
    }
    
    private func setupController() {
        view.addSubview(collectionView)
        view.backgroundColor = .white
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}

// MARK: - CollectionViewCell
private extension ViewController {
    final class CollectionViewCell: UICollectionViewCell {
        
        static let identifier = String(describing: CollectionViewCell.self)
        
        private lazy var textLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "Tags"
            label.font = .systemFont(ofSize: 11)
            label.textAlignment = .center
            return label
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupCell()
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupCell() {
            contentView.addSubview(textLabel)
            contentView.layer.borderWidth = 2
            contentView.layer.cornerRadius = frame.height / 2
            contentView.layer.borderColor = UIColor.blue.cgColor
            
            setupConstraints()
        }
        
        private func setupConstraints() {
            NSLayoutConstraint.activate([
                textLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                textLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                textLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                textLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
            ])
        }
    }
}

// MARK: - CollectionViewLayout
private extension ViewController {
    final class CollectionViewLayout: UICollectionViewLayout {
        
        private var attributesCache: [UICollectionViewLayoutAttributes] = []
        private var contentHeight: CGFloat = 0
        private let cellHeight: CGFloat = 40
        private let horizontalPadding: CGFloat = 10
        private let verticalPadding: CGFloat = 15
        private let startY: CGFloat = 20
        private var contentSize: CGSize = .zero
        
        var data: Data?
        
        override func prepare() {
            guard let collectionView = collectionView,
                  let data = data else { return }
            
            showData(data: data)
            
            attributesCache.removeAll()
            
            var yOffset: CGFloat = startY
            var itemIndex = 0
            
            let containerWidth = collectionView.bounds.width
            
            for row in data.elements {
                var totalRowWidth: CGFloat = 0
                var cellWidths: [CGFloat] = []
                
                for cellSize in row {
                    let cellWidth: CGFloat = containerWidth * CGFloat(cellSize.rawValue)
                    cellWidths.append(cellWidth)
                    totalRowWidth += cellWidth
                }
                
                totalRowWidth += CGFloat(row.count - 1) * horizontalPadding
                
                if totalRowWidth > containerWidth {
                    let scaleFactor = (containerWidth - CGFloat(row.count - 1) * horizontalPadding) / totalRowWidth
                    for i in 0..<cellWidths.count {
                        cellWidths[i] *= scaleFactor
                    }
                }
                
                var xOffset: CGFloat = 0
                
                switch data.alignment {
                case .left:
                    xOffset = 10
                case .center:
                    if totalRowWidth <= containerWidth {
                        xOffset = (containerWidth - totalRowWidth) / 2
                    } else {
                        xOffset = 10
                    }
                case .right:
                    if totalRowWidth <= containerWidth {
                        xOffset = containerWidth - totalRowWidth - 20
                    } else {
                        xOffset = 10
                    }
                }

                for cellWidth in cellWidths {
                    let indexPath = IndexPath(item: itemIndex, section: 0)
                    let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    
                    attributes.frame = CGRect(x: xOffset, y: yOffset, width: cellWidth, height: cellHeight)
                    attributesCache.append(attributes)
                    
                    xOffset += cellWidth + horizontalPadding
                    itemIndex += 1
                }
                
                yOffset += cellHeight + verticalPadding
            }
            
            contentHeight = yOffset
            contentSize = collectionView.bounds.size
        }

        override var collectionViewContentSize: CGSize {
            return contentSize
        }

        override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
            return attributesCache.filter { $0.frame.intersects(rect) }
        }

        override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
            return attributesCache[indexPath.item]
        }
        
        private func showData(data: Data) {
            data.elements.forEach { (value: [Size]) in
                if value.isEmpty {
                    fatalError()
                }
                
                if value.reduce(0.0, { $0 + $1.rawValue }) > 1 {
                    fatalError()
                }
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numberOfElements = 0
        collectionData.elements.forEach { numberOfElements += $0.count }
        return numberOfElements
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier, for: indexPath) as? CollectionViewCell else {
            return UICollectionViewCell()
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension ViewController: UICollectionViewDelegate { }
