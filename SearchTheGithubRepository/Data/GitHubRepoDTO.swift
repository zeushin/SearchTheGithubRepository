//
//  GitHubRepoDTO.swift
//  SearchTheGithubRepository
//
//  Created by Masher Shin on 9/22/24.
//

import Foundation

struct GitHubRepoDTO: Decodable {
    let total_count: Int
    let items: [GitHubRepoItemDto]
}

extension GitHubRepoDTO {
    struct GitHubRepoItemDto: Decodable {
        let id: Int
        let name: String
        let owner: GitHubRepoOwnerDto
        let html_url: String
        let description: String?
        let license: GitHubRepoLicenseDto?
        let stargazers_count: Int
    }

    struct GitHubRepoOwnerDto: Decodable {
        let login: String
        let avatar_url: String?
        let html_url: String
    }

    struct GitHubRepoLicenseDto: Decodable {
        let spdx_id: String
    }
}
