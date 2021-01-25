//
// The MIT License (MIT)
//
// Copyright (c) 2021 David Costa Gonçalves
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation

struct RestaurantDto {
    
    /// (integer, optional): ID of the restaurant
    let id: String
    
    /// (string, optional): Name of the restaurant
    let name: String
    
    /// (string, optional): URL of the restaurant page
    let url: String?
    
    /// (string, optional): Short URL of the restaurant page; for use in apps or social shares
    let deeplink: String?
    
    /// (ResLocation, optional): Restaurant location details
    let location: LocationDto?
    
    /// /// (integer, optional): Price bracket of the restaurant (1 being pocket friendly and 4 being the costliest)
    let priceRange: Int?
    
    /// (string, optional): Local currency symbol; to be used with price
    let currency: String?
    
    /// (string, optional): URL of the low resolution header image of restaurant
    let thumb: String?
    
    /// (string, optional): URL of the high resolution header image of restaurant
    //let featured_image: String?
    
    let timings: String?
    
    /// (string, optional): URL of the restaurant's menu page
    let menuUrl: String?
    
    /// (UserRating, optional): Restaurant rating details
    // let user_rating: UserRating?
    
    /// (boolean, optional): Whether the restaurant has online delivery enabled or not
    // let has_online_delivery: Int?//Bool?
    
    /// (boolean, optional): Valid only if has_online_delivery = 1; whether the restaurant is accepting online orders right now
    // let is_delivering_now: Int?//Bool?
    
    /// (boolean, optional): Whether the restaurant has table reservation enabled or not
    // let has_table_booking: Int?//Bool?
    
    /// (string, optional): List of cuisines served at the restaurant in csv format
    let cuisines: String?
    
    /// (integer, optional): [Partner access] Number of reviews for the restaurant
    //let all_reviews_count: Int?
    
    /// (integer, optional): [Partner access] Total number of photos for the restaurant, at max 10 photos for partner access
    //let photo_count: Int?
    
    /// (string, optional): [Partner access] Restaurant's contact numbers in csv format
    let phoneNumbers: String?
    
    /// (Array[Photo], optional): [Partner access] List of restaurant photos
    // let photos: [Photo]?
    
}
