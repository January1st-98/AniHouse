//
//  SelectedFreeBoardView.swift
//  AniHouse-iOS
//
//  Created by 최은성 on 2022/04/05.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

struct SelectedFreeBoardView: View {
    @EnvironmentObject var freeFirestoreViewModel: FreeBoardViewModel
    @EnvironmentObject var userInfoManager: UserInfoViewModel
    
    @State var post: FreeBoardContent = FreeBoardContent() // 게시글 객체를 넘겨받음.
    
    @State var showingAlert = false
    @State var showModal = false
    @Environment(\.presentationMode) var presentationMode
    
    let user = Auth.auth().currentUser
    
    @State var hitValue: Int = 0 // 현재 좋아요 개수
    
    @State private var animate = false // 애니매이션 동작여부
    @State var isLiked: Bool = false // 현재 유저가 좋아요를 체크했는지 여부
    @State var dateString: String = ""
    @State var idGetComment: Bool = false
    @State var currentComments: [Comment] = [Comment]()
    @State var writerNickName: String? = nil
    
    //알림여부
    @State var showPostDeleteButton: Bool = false
    @State var showAlert: Bool = false
    @State var showDeleteAlert: Bool = false
    @State var showReportAlert: Bool = false
    @State var showBlockAlert: Bool = false
    
    @State var formatter: DateFormatter = DateFormatter()
    
    @State var writerProfileImage: UIImage? = nil
    
    private let animationDuration: Double = 0.1
    private var animationScale: CGFloat {
        self.isLiked ? 0.7 : 1.3
    }
    
    @State private var isPresented: Bool = false
    @State private var commentField: String = ""
    
    @Binding var showingOverlay: Bool
    
    @State private var isActive = false
    
    var body: some View {
        VStack(alignment: .leading) {
            // 게시글 제목
            HStack {
                //MARK: - 게시글 정보, 작성자 정보 출력
                HStack {
                    //MARK: - 게시글 작성자 프로필 이미지 출력
                    
                    
                    if let writerProfileImage = writerProfileImage {
                        Image(uiImage: writerProfileImage)
                            .resizable()
                            .frame(width: 40, height: 40)
                            .scaledToFill()
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(lineWidth: 1)
                            )
                    } else {
                        Image(Constant.ImageName.defaultUserImage)
                            .resizable()
                            .frame(width: 40, height: 40)
                            .scaledToFill()
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(lineWidth: 1)
                            )
                    }
                    // 게시글 작성자
                    //MARK: - 게시글 작성자, 날짜 출력
                    VStack(alignment: .leading) {
                        if let writerNickName = writerNickName {
                            Text(writerNickName)
                                .fontWeight(.semibold)
                                .font(.system(size: 20))
                        } else {
                            Text("nickname")
                                .font(.system(size: 13))
                        }
                        Text(self.dateString)
                            .foregroundColor(.secondary)
                            .font(.system(size: 11))
                    }
                    .padding([.trailing])
                }
                Spacer()
                
                // 게시글 좋아요 버튼
                Button(action: {
                    //action
                    if isLiked {
                        /// 게시글의 좋아요를 누른 상태일 때 Like를 지운다.
                        //                                DispatchQueue.main.async {
                        freeFirestoreViewModel.deleteLike(post: self.post, currentUser: self.user?.email ?? "")
                        //                                }
                        self.isLiked.toggle()
                        hitValue -= 1
                    } else {
                        /// 좋아요를 누르지 않은 상태일 때
                        //                                DispatchQueue.main.async {
                        freeFirestoreViewModel.addLike(post: self.post, currentUser: self.user?.email ?? "")
                        
                        //                                }
                        self.isLiked.toggle()
                        hitValue += 1
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + self.animationDuration, execute: {
                        self.animate = false
                    })
                }, label: {
                    Image(systemName: self.isLiked ? "heart.fill" : "heart")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(self.isLiked ? .red : .gray)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 3)
                })
                    .buttonStyle(BorderlessButtonStyle())
                    .padding(.leading)
                    .scaleEffect(animate ? animationScale : 1)
                    .animation(Animation.easeIn(duration: animationDuration), value: animationScale)
                
                Text("\(self.hitValue)")
                    .font(.system(size: 16))
                
            }
            .onAppear {
                self.hitValue = post.hit
                if post.likeUsers.contains(user?.email ?? "") {
                    isLiked = true
                } else {
                    isLiked = false
                }
                
                self.formatter = DateFormatter()
                self.formatter.dateFormat = "yyyy년 MM월 dd일 HH:mm"
                print("post.date = \(post.date)")
                dateString = self.formatter.string(from: self.post.date)
                
            }
            
            
            
            // 구분선
            Divider()
            
            // 게시글 내용
            VStack(alignment: .leading) {
                Text(post.body)
                    .font(.system(size: 16))
            }
            .padding([.top, .bottom])
            
            // 구분선
            Divider()
            
            ScrollView {
                ForEach(self.freeFirestoreViewModel.comments.indices, id: \.self.hashValue) { idx in
                    FreeCommentView(email: freeFirestoreViewModel.comments[idx].email,
                                    currentCommentId: freeFirestoreViewModel.comments[idx].id,
                                    nickName: freeFirestoreViewModel.comments[idx].nickName,
                                    content: freeFirestoreViewModel.comments[idx].content,
                                    date: freeFirestoreViewModel.comments[idx].date,
                                    isCommentUser: user!.email! == freeFirestoreViewModel.comments[idx].email,
                                    documentId: self.post.id,
                                    isBlockedUser: userInfoManager.userBlockList.contains(freeFirestoreViewModel.comments[idx].email))
                    
                    
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            // dots 클릭 시, 게시글 삭제 버튼과 수정 버튼 표시
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Menu {
                        if showPostDeleteButton {
                            Button(action: {
                                print("게시글 수정 버튼 pressed")
                                self.isActive = true
                            }, label: {
                                Label("수정하기", systemImage: "square.and.pencil")
                            })
                            Button(action: {
                                // 삭제 @State값을 토글한다.
                                self.showAlert = true
                                self.showDeleteAlert = true
                                self.showReportAlert = false
                                self.showBlockAlert = false
                                print("게시글 삭제 버튼 pressed")
                            }, label: {
                                Label("삭제하기", systemImage: "trash")
                            })
                        } else {
                            Button(action: {
                                print("게시글 신고 버튼 pressed")
                                self.showAlert = true
                                self.showReportAlert = true
                                self.showDeleteAlert = false
                                self.showBlockAlert = false
                            }, label: {
                                Label("신고하기", systemImage: "flag")
                            })
                            
                            Button {
                                self.showAlert = true
                                self.showBlockAlert = true
                                self.showDeleteAlert = false
                                self.showReportAlert = false
                            } label: {
                                Label("이 유저 차단하기", systemImage: "nosign")
                            }

                        }
                    } label: {
                        Image(Constant.ImageName.dots)
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                    .background {
                        NavigationLink(destination: ReviseFreeBoardView(post: post), isActive: $isActive) {
                            EmptyView()
                        }
                    }
                    //                    .disabled(showPostDeleteButton ? false : true)
                    .menuStyle(.automatic)
                    .alert(isPresented: self.$showAlert) {
                        if showDeleteAlert {
                            return Alert(title: Text("게시글을 삭제하시겠습니까?"),
                                         message: Text("삭제한 게시글은 복구할 수 없습니다."),
                                         primaryButton: .destructive(Text("삭제"), action: {
                                freeFirestoreViewModel.deletePost(postId: self.post.id)
                            }),
                                         secondaryButton: .cancel(Text("취소")))
                        }
                        else if showReportAlert {
                            return Alert(title: Text("신고"), message: Text("부적절한 내용 발견시 삭제조치됩니다"), primaryButton: .default(Text("신고하기"), action: {
                                freeFirestoreViewModel.reportFreePost(postId: post.id)
                            }), secondaryButton: .destructive(Text("취소")))
                        }
                        return Alert(title: Text("이 유저를 차단하시겠습니까?"),
                                     message: Text("차단 후에는 이 유저가 쓴 글과 댓글이 보이지 않습니다"),
                                     primaryButton: .destructive(Text("차단"), action: {
                            print("차단버튼을 눌렀어요")
                            userInfoManager.addBlockUser(blockEmail: post.author)
                            presentationMode.wrappedValue.dismiss() // 이전 화면으로 돌아감.
                        }), secondaryButton: .default(Text("아니오")))
                        
                        
                    }
                }
            }
            Divider()
            Spacer()
            FreeAddCommentView(currentPost: self.post, currentComments: self.$currentComments)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(post.title)
        .onAppear {
            freeFirestoreViewModel.getComment(collectionName: "FreeBoard", documentId: self.post.id)
            print("model.comments: \(freeFirestoreViewModel.comments)")
            for comment in freeFirestoreViewModel.comments {
                self.currentComments.append(comment)
            }
            if user!.email! == post.author {
                self.showPostDeleteButton = true
            }
            getWriterNickName()
            getProfileImage()
            
            
        }
        .onAppear {
            showingOverlay = false
        }
        .padding(5)
        .cornerRadius(12)
        .background(Color(Constant.CustomColor.lightBrown).edgesIgnoringSafeArea(.all))
        
    }
    
    func getProfileImage() {
        let storage = Storage.storage()
        let profileImageRef = storage.reference().child("user/profileImage/\(post.author)")
        profileImageRef.getData(maxSize: 1*1024*1024) { data, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("SelectedMainPost - \(post.author) 의 프로필사진을 찾았습니다!")
                DispatchQueue.main.async {
                    self.writerProfileImage = UIImage(data: data!)!
                }
                
            }
        }
    }
    func getWriterNickName() {
        let db = Firestore.firestore()
        print("SelectedMainPost - getWriterNickName")
        db.collection("userInfo").document(post.author).getDocument { snapshot, error in
            if let snapshot = snapshot {
                self.writerNickName = snapshot.get("nickName") as? String
                print("게시글 작성자의 닉네임을 가져왔어요! -> \(writerNickName)")
            }
        }
    }
    
}
//struct SelectedFreeBoardView_Previews: PreviewProvider {
//    static var previews: some View {
//        SelectedFreeBoardView(post: FreeBoardContent())
//    }
//}
//
