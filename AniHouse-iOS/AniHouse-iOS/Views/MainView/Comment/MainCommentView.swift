//
//  MainCommentView.swift
//  AniHouse-iOS
//
//  Created by Jaehoon So on 2022/05/12.
//

import SwiftUI
import FirebaseStorage

struct MainCommentView: View {
    
    @EnvironmentObject var mainFirestoreViewModel: MainPostViewModel
    @EnvironmentObject var userInfoManager: UserInfoViewModel
    
    
    @State var profileImage: UIImage? = nil
    
    var email: String?
    var nickName: String?
    var content: String?
    var date: Date?
    var currentCommentId: String = ""
    @State var dateString: String = ""
    @State var formatter = DateFormatter()
    var isCommentUser = false
    var documentId: String = ""
    var isBlockedUser: Bool = false
    
    @State var showDeleteAlert: Bool = false
    @State var showReportAlert: Bool = false
    
    init(email: String, currentCommentId: String, nickName: String, content: String, date: Date, isCommentUser: Bool, documentId: String, isBlockedUser: Bool) {
        self.email = email
        self.currentCommentId = currentCommentId
        self.nickName = nickName
        self.content = content
        self.date = date
        self.isCommentUser = isCommentUser
        self.documentId = documentId
        self.isBlockedUser = isBlockedUser
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Rectangle().frame(height: 0)
            HStack{
                
                if profileImage == nil {
                    Image(systemName: "person")
                        .foregroundColor(.black)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(lineWidth: 1)

                        )
                } else {
                    Image(uiImage: profileImage!)
                        .resizable()
                        .scaledToFill()
                        .foregroundColor(.black)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(lineWidth: 1)
                        )
                }
                
                VStack(alignment: .leading) {
                    Text(!isBlockedUser ? nickName! : "????????? ?????????")
                        .fontWeight(.semibold)
                    Text(dateString)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                Button {
                    self.showDeleteAlert = true
                } label: {
                    Image(systemName: isCommentUser ? "trash" : "")
                        .foregroundColor(.red)
                        .font(.system(size: 15))
                }
                .padding(0)
                .alert(isPresented: self.$showDeleteAlert) {
                    Alert(title: Text("????????? ?????????????????????????"), message: Text("????????? ????????? ????????? ??? ????????????."), primaryButton: .destructive(Text("??????"), action: {
                        withAnimation {
                            mainFirestoreViewModel.deleteComment(collectionName: "MainPost", documentId: documentId, commentId: currentCommentId)
                        }
                    }), secondaryButton: .cancel(Text("??????")))
                }
                Spacer()
                    .frame(width: 12)
                Button {
                    self.showReportAlert = true
                } label: {
                    Image(systemName: "flag")
                }
                .alert(isPresented: self.$showReportAlert) {
                    Alert(title: Text("????????? ?????????????????????????"), message: Text("????????? ????????? ?????? ??? ???????????????."),
                          primaryButton: .destructive(Text("??????"), action: {
                        withAnimation {
                            print("??????????????? ????????????!")
                        }
                    }),secondaryButton: .cancel(Text("??????")))
                }
            }
            Text(!isBlockedUser ? content! : "????????? ????????? ?????????")
                .fontWeight(.light)
                .padding(.leading, 5)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 3)
        .background(Color(Constant.CustomColor.muchLightBrown))
        .cornerRadius(5)
        .onAppear {
            self.formatter.dateFormat = "yyyy??? MM??? dd??? HH:mm"
            self.dateString = formatter.string(from: self.date!)
            print("asdf: \(self.isCommentUser)")
            print("MainCommentView - currentComment.id = \(currentCommentId)")
            getProfileImage()
            
            
        }
    }
    
    func getProfileImage() {
        let storage = Storage.storage()
        let profileImageRef = storage.reference().child("user/profileImage/\(email!)")
        profileImageRef.getData(maxSize: 1*1024*1024) { data, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("\(email!) ??? ?????????????????? ???????????????!")
                DispatchQueue.main.async {
                    self.profileImage = UIImage(data: data!)!
                }
                
            }
            
        }
        
    }
    
}

struct MainCommentView_Previews: PreviewProvider {
    static var previews: some View {
        MainCommentView(email: "", currentCommentId: "", nickName: "?????????", content: "???????????????~~", date: Date(), isCommentUser: false, documentId: "", isBlockedUser: false)
    }
}
