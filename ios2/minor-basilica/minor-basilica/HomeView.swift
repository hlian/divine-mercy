//
//  HomeView.swift
//  minor-basilica
//
//  Created by hao on 6/12/17.
//
//

import Foundation
import UIKit

struct Post {
    let text = "hey baby"
    let image = "https://energy.gov/sites/prod/files/wv_theme2_image.jpg"
}

enum PostBP {
    case Loading(labelFrame: CGRect, loadingFrame: CGRect)
    case Good(labelFrame: CGRect, imageFrame: CGRect)

    static func makeLoading(post: Post, insets: UIEdgeInsets, width: CGFloat) -> PostBP {
        let labelW = width - insets.left - insets.right
        let labelH = post.text.heightWithConstrainedWidth(width: labelW, font: UIFont.systemFont(ofSize: 13))
        let labelFrame = CGRect(x: insets.left, y: insets.top, width: labelW, height: labelH)
        let loadingFrame = CGRect(x: labelFrame.minX, y: labelFrame.maxY + 5, width: width, height: 10)
        return PostBP.Loading(labelFrame: labelFrame, loadingFrame: loadingFrame)
    }
}

func ==(lhs: PostBP, rhs: PostBP) -> Bool {
    switch (lhs, rhs) {
    case let (.Loading(x, y), .Loading(z, w)):
        return x == z && y == w
    case let (.Good(x, y), .Good(z, w)):
        return x == z && y == w
    default:
        return false
    }
}

enum CollectionDiffHunk {
    case Reload(path: IndexPath)
    case Insert(path: IndexPath)
    case Delete(path: IndexPath)
}

class HomeVML {
    var posts: [PostBP]!

    static func diff(old: HomeVML, new: HomeVML) -> [CollectionDiffHunk] {
        var hunks = [CollectionDiffHunk]()
        var oldI = 0, newI = 0
        while (oldI < old.posts.count) {
            if (old.posts[oldI] == new.posts[newI]) {
                oldI += 1
                newI += 1
            }
        }
        return hunks
    }
}


class HomeVM: NSObject, UICollectionViewDelegateFlowLayout {
    let layout = UICollectionViewFlowLayout()
    let view: UICollectionView
    let ds: HomeDS
    var bp: [PostBP]!

    override init() {
        self.view = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.layout)
        let posts: [Post] = [Post](repeating: Post(), count: 100)
        self.ds = HomeDS(posts: posts)
        super.init()

        view.delegate = self
        view.dataSource = ds
        view.register(HomeCell.self, forCellWithReuseIdentifier: ".")
    }

    static func make() -> HomeVM {
        let v: HomeVM = HomeVM()
        v.view.backgroundColor = UIColor(hex: 0xeeeeee)
        return v
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.bounds.size.width, height: 150)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
    }
}

class HomeDS: NSObject, UICollectionViewDataSource {
    let posts: [Post]
    init(posts: [Post]) {
        self.posts = posts
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        assert(section == 0)
        return posts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: HomeCell = collectionView.dequeueReusableCell(withReuseIdentifier: ".", for: indexPath) as! HomeCell
        cell.absorb(posts[indexPath.row])
        return cell
    }
}

enum HomeCellState {
    case Good
    case Bad
    case Loading
}

class HomeCell: UICollectionViewCell {
    let label: UILabel
    let image: UIImageView
    let loadingView: UIView
    let state = HomeCellState.Loading
    let insets = UIEdgeInsetsMake(10, 10, 10, 10)

    override init(frame: CGRect) {
        label = UILabel()
        image = UIImageView()
        loadingView = UIView()

        super.init(frame: frame)

        self.isOpaque = true
        self.clipsToBounds = true
        layer.borderColor = UIColor.blue.cgColor
        layer.borderWidth = 1

        addSubview(label)
        addSubview(image)
        addSubview(loadingView)
    }

    override func layoutSubviews() {
        let labelW = bounds.size.width - insets.left - insets.right
        let labelH = label.text!.heightWithConstrainedWidth(width: labelW, font: label.font)
        label.frame = CGRect(x: insets.left, y: insets.top, width: labelW, height: labelH)
        label.debug(UIColor.red)
        loadingView.frame = CGRect(x: label.frame.minX, y: label.frame.maxY + 5, width: label.frame.width, height: 10)
        loadingView.backgroundColor = UIColor.brown
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("unimplemented")
    }

    func absorb(_ post: Post) {
        label.text = post.text
        to(HomeCellState.Loading)
    }

    func to(_ state: HomeCellState) {
        switch state {
        case .Loading:
            image.isHidden = true
            loadingView.isHidden = false
        default:
            break
        }
        setNeedsLayout()
    }
}
