//
//  MainViewModel.swift
//  Sparta9_NetflixClone
//
//  Created by seohuibaek on 12/27/24.
//

import Foundation
import RxSwift

//비즈니스 로직 작성

class MainViewModel {
    private let apikey: String = "84108123751028886408bed371c6d2a5"
    private let disposeBag = DisposeBag()
    
    ///View가 구독할 subject
    let popularMovieSubject = BehaviorSubject(value: [Movie]())
    let topRatedMovieSubject = BehaviorSubject(value: [Movie]())
    let upcomingMovieSubject = BehaviorSubject(value: [Movie]())

    init() {
        fetchPopularMovie()
        fetchTopRatedMovie()
        fetchUpcomingMovie()
    }
    
    /// Popular Movie 데이터 불러오기
    func fetchPopularMovie() {
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/popular?api_key=\(apikey)") else {
            popularMovieSubject.onError(NetworkError.invalidUrl)
            return
        }
        
        NetworkManager.shared.fetch(url: url)
            .subscribe(onSuccess: { [weak self] (movieResponse: MovieResponse) in
                self?.popularMovieSubject.onNext(movieResponse.results)
            }, onFailure: { [weak self] error in
                self?.popularMovieSubject.onError(error)
            }).disposed(by: disposeBag)
    }
    
    func fetchTopRatedMovie() {
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/top_rated?api_key=\(apikey)") else {
            topRatedMovieSubject.onError(NetworkError.invalidUrl)
            return
        }
        
        NetworkManager.shared.fetch(url: url)
            .subscribe(onSuccess: { [weak self] (movieResponse: MovieResponse) in
                self?.topRatedMovieSubject.onNext(movieResponse.results)
            }, onFailure: { [weak self] error in
                self?.topRatedMovieSubject.onError(error)
            }).disposed(by: disposeBag)
    }
    
    func fetchUpcomingMovie() {
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/upcoming?api_key=\(apikey)") else {
            upcomingMovieSubject.onError(NetworkError.invalidUrl)
            return
        }
        
        NetworkManager.shared.fetch(url: url)
            .subscribe(onSuccess: { [weak self] (movieResponse: MovieResponse) in
                self?.upcomingMovieSubject.onNext(movieResponse.results)
            }, onFailure: { [weak self] error in
                self?.upcomingMovieSubject.onError(error)
            }).disposed(by: disposeBag)
    }
    
    func fetchTrailerKey(movie: Movie) -> Single<String> {
        guard let movieId = movie.id else {
            return Single.error(NetworkError.dataFetchFail)
        }
        
        let urlString = "https://api.themoviedb.org/3/movie/\(movieId)/videos?api_key=\(apikey)"
        
        guard let url = URL(string: urlString) else {
            return Single.error(NetworkError.invalidUrl)
        }
        
        return NetworkManager.shared.fetch(url: url)
            .flatMap { (VideoResponse: VideoResponse) -> Single<String> in
                if let trailer = VideoResponse.results.first(where: {$0.type == "Trailer" && $0.site == "YouTube"}) {
                    guard let key = trailer.key else {
                        return Single.error(NetworkError.dataFetchFail)
                    }
                    return Single.just(key)
                } else {
                    return Single.error(NetworkError.dataFetchFail)
                }
            }
    }
}
