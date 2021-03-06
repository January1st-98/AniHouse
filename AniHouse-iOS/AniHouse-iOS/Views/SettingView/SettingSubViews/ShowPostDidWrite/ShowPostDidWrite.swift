//
//  ShowPostDidWrite.swift
//  AniHouse-iOS
//
//  Created by Jaehoon So on 2022/05/25.
//

import SwiftUI

struct ShowPostDidWrite: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var mainPostViewModel: MainPostViewModel
    @EnvironmentObject var freeBoardViewModel: FreeBoardViewModel
    @EnvironmentObject var userInfoViewModel: UserInfoViewModel
    
    @State var isPresented: Bool = true
    
    var body: some View {
        VStack {
            List {
                Section("우리 가족 소개하기") {
                    ForEach(self.mainPostViewModel.userMainPost.indices, id: \.self.hashValue) { idx in
                        NavigationLink {
                            SelectedMainPost(post: self.mainPostViewModel.userMainPost[idx])
                        } label: {
                            VStack(alignment: .leading) {
                                Text(self.mainPostViewModel.userMainPost[idx].title)
                                    .fontWeight(.semibold)
                                    .padding(.bottom, 1)
                                Text(self.mainPostViewModel.userMainPost[idx].body)
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 13))
                            }
                        }
                    }
                }
                Section("자유게시판") {
                    ForEach(self.freeBoardViewModel.userFreePost.indices, id: \.self.hashValue) { idx in
                        NavigationLink {
                            SelectedFreeBoardView(post: self.freeBoardViewModel.userFreePost[idx], showingOverlay: $isPresented)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(self.freeBoardViewModel.userFreePost[idx].title)
                                    .fontWeight(.semibold)
                                    .padding(.bottom, 1)
                                Text(self.freeBoardViewModel.userFreePost[idx].body)
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 13))
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
//        .background(Color(Constant.CustomColor.normalBrown))
        .navigationTitle("✍️ 내가 쓴 게시글")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                }
                
            }
        }
        .onAppear {
            print("email: \(userInfoViewModel.user!.email!)")
            mainPostViewModel.getCurrentUserMainPost(email: userInfoViewModel.user!.email!) // 유저가 메인 게시판에 쓴 글을 불러온다.
            freeBoardViewModel.getCurrentUserFreePost(email: userInfoViewModel.user!.email!) // 유저가 자유 게시판에 쓴 글을 불러온다.
        }
    }
}


struct ShowPostDidWrite_Previews: PreviewProvider {
    static var previews: some View {
        ShowPostDidWrite()
    }
}
