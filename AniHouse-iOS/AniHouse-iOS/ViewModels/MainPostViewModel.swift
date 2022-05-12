//
//  MainPostViewModel.swift
//  AniHouse-iOS
//
//  Created by Jaehoon So on 2022/05/05.
//

import Foundation
import Firebase

class MainPostViewModel: ObservableObject {
    @Published var posts: [MainPost] = [MainPost]()
    @Published var comments: [Comment] = [Comment]()
    @Published var currentPostId: String = ""
    @Published var uploadPostId: String = ""
    
    private var dummyComment = Comment(id: "comment id", author: "author", content: "body", date: Date())
    
    //MARK: - 데이터 읽기
    func getData() {
        let db = Firestore.firestore()
        
        db.collection("MainPost").order(by: "date", descending: true).getDocuments { snapshot, error in
            guard error == nil else { return }
            if let snapshot = snapshot {
                DispatchQueue.main.async {
                    self.posts = snapshot.documents.map { data in
                        let post =  MainPost(id: data.documentID,
                                             title: data["title"] as? String ?? "",
                                             body: data["body"] as? String ?? "",
                                             author: data["author"] as? String ?? "",
                                             hit: data["hit"] as? Int ?? 0,
                                             likeUsers: data["likeUser"] as? [String] ?? [],
                                             date: data["date"] as? Date ?? Date())
                        self.currentPostId = data.documentID
                        return post
                    }
                }
            } else {
                // error
                // snapshot이 없음.
            }
        }
        
    }
    
    func getComment() {
        let db = Firestore.firestore()
        
        db.collection("MainPost").document(currentPostId)
            .collection("comment").getDocuments { snapshot, error in
                guard error == nil else { return }
                if let snapshot = snapshot {
                    self.comments = snapshot.documents.map { data in
                        return Comment(id: data.documentID,
                                       author: data["author"] as? String ?? "",
                                       content: data["content"] as? String ?? "",
                                       date: data["date"] as? Date ?? Date())
                    }
                }
            }
    }
    
    func getPostId() {
        
    }
    
    //MARK: - 데이터 쓰기
    func addData(title: String, body: String, image: UIImage, author: String, hit: Int, date: Date) {
        print("MainPostViewModel - addData()")
        let db = Firestore.firestore()
        let ref = db.collection("MainPost").document()
        let id = ref.documentID
        
        ref.setData(["title": title,
                     "body": body,
                     "author": author,
                     "hit": hit,
                     "likeUser": [],
                     "date": date]) { error in
            guard error == nil else { return }
        }
        self.uploadPostId = id
        self.getData()
    }
    
    func addComment(author: String, date: Date, content: String) {
        let db = Firestore.firestore()
        db.collection("MainPost").document(currentPostId)
            .collection("comment").addDocument(data: ["author": author,
                                                      "date": date,
                                                      "content": content]) { error in
                guard error == nil else { return }
                self.getData()
            }
    }
    
    /// post: 현재 접근한 글
    /// currentUser: 글의 좋아요 유저 목록에서 추가할 유저의 이메일
    func addLike(post: MainPost, currentUser: String) {
        let db = Firestore.firestore()
        var currentLikeUsers = post.likeUsers
        /// 파이어베이스 딜레이를 방지하기위해서 혹시 이미 배열 내부에 유저가 있을 때만 추가.
        if(!currentLikeUsers.contains(currentUser)) {
            currentLikeUsers.append(currentUser)
        }
//        let currentHit = post.hit + 1
        db.collection("MainPost").document(post.id).setData(["likeUser": currentLikeUsers, "hit": currentLikeUsers.count], merge: true) { error in
            if let e = error { print(e.localizedDescription) }
        }
        self.getData()
    }
    
    /// post: 현재 접근한 글
    /// currentUser: 글의 좋아요 유저 목록에서 지울 유저의 이메일
    func deleteLike(post: MainPost, currentUser: String) {
        let db = Firestore.firestore()
        let currentLikeUsers = post.likeUsers.filter { $0 != currentUser }
        db.collection("MainPost").document(post.id).setData(["likeUser": currentLikeUsers, "hit": currentLikeUsers.count], merge: true) { error in
            if let e = error { print(e.localizedDescription) }
        }
        
        self.getData()
    }
    
}