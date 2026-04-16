//
//  DataBaseModel.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 06/03/26.
//

import Foundation
import SwiftData

// MARK: - SwiftData Models matching GameCast.json

@Model
final class Gamecast: Identifiable {
    @Attribute(.unique) var id: UUID
    var mainEvent: String
    var mainEventAction: String
    var createdByUserId: Int
    var teamGameId: Int
    var gameId: Int
    var teamId: Int
    @Relationship(deleteRule: .cascade) var pitchData: PitchData?
    @Relationship(deleteRule: .cascade) var scoring: Scoring?

    init(id: UUID = UUID(), mainEvent: String, mainEventAction: String, createdByUserId: Int, teamGameId: Int, gameId: Int, teamId: Int, pitchData: PitchData? = nil, scoring: Scoring? = nil) {
        self.id = id
        self.mainEvent = mainEvent
        self.mainEventAction = mainEventAction
        self.createdByUserId = createdByUserId
        self.teamGameId = teamGameId
        self.gameId = gameId
        self.teamId = teamId
        self.pitchData = pitchData
        self.scoring = scoring
    }
}

@Model
final class PitchData: Identifiable {
    @Attribute(.unique) var id: UUID
    var actionId: String
    var currentPitcher: Int
    var currentBatter: Int

    @Relationship(deleteRule: .cascade) var fielderInvolved: [FielderInvolved]
    @Relationship(deleteRule: .cascade) var safeOrOut: SafeOrOut?

    init(id: UUID = UUID(), actionId: String, currentPitcher: Int, currentBatter: Int, fielderInvolved: [FielderInvolved] = [], safeOrOut: SafeOrOut? = nil) {
        self.id = id
        self.actionId = actionId
        self.currentPitcher = currentPitcher
        self.currentBatter = currentBatter
        self.fielderInvolved = fielderInvolved
        self.safeOrOut = safeOrOut
    }
}

@Model
final class FielderInvolved: Identifiable {
    @Attribute(.unique) var id: UUID
    var fieldedByPlayerId: Int
    @Relationship(deleteRule: .cascade) var fieldedHitPoint: Point?

    init(id: UUID = UUID(), fieldedByPlayerId: Int, fieldedHitPoint: Point? = nil) {
        self.id = id
        self.fieldedByPlayerId = fieldedByPlayerId
        self.fieldedHitPoint = fieldedHitPoint
    }
}

@Model
final class Point: Identifiable {
    @Attribute(.unique) var id: UUID
    var x: Double
    var y: Double

    init(id: UUID = UUID(), x: Double, y: Double) {
        self.id = id
        self.x = x
        self.y = y
    }
}

@Model
final class SafeOrOut: Identifiable {
    @Attribute(.unique) var id: UUID
    @Relationship(deleteRule: .cascade) var batter: PlayerRemoval?
    @Relationship(deleteRule: .cascade) var runners: [PlayerRemoval]

    init(id: UUID = UUID(), batter: PlayerRemoval? = nil, runners: [PlayerRemoval] = []) {
        self.id = id
        self.batter = batter
        self.runners = runners
    }
}

@Model
final class PlayerRemoval: Identifiable {
    @Attribute(.unique) var id: UUID
    var playerId: Int
    var name: String
    var onWhichBasePlayerRemoved: String
    var status: String

    init(id: UUID = UUID(), playerId: Int, name: String, onWhichBasePlayerRemoved: String, status: String) {
        self.id = id
        self.playerId = playerId
        self.name = name
        self.onWhichBasePlayerRemoved = onWhichBasePlayerRemoved
        self.status = status
    }
}

@Model
final class Scoring: Identifiable {
    @Attribute(.unique) var id: UUID
    var inningsNumber: Int
    var isBottom: Bool
    var outs: Int
    var strikes: Int
    var balls: Int
    var awayScore: Int
    var homeScore: Int

    @Relationship(deleteRule: .cascade) var awayTeam: TeamSummary?
    @Relationship(deleteRule: .cascade) var homeTeam: TeamSummary?

    @Relationship(deleteRule: .cascade) var baseOccupancy: BaseOccupancy?

    @Relationship(deleteRule: .cascade) var currentBatter: PlayerSummary?
    @Relationship(deleteRule: .cascade) var currentPitcher: PlayerSummary?

    @Relationship(deleteRule: .cascade) var awayLineUp: [PlayerSummary]
    @Relationship(deleteRule: .cascade) var homeLineUp: [PlayerSummary]
    @Relationship(deleteRule: .cascade) var awayLineUpBench: [PlayerSummary]
    @Relationship(deleteRule: .cascade) var homeLineUpBench: [PlayerSummary]

    @Relationship(deleteRule: .cascade) var playByPlay: PlayByPlay?

    init(
        id: UUID = UUID(),
        inningsNumber: Int,
        isBottom: Bool,
        outs: Int,
        strikes: Int,
        balls: Int,
        awayScore: Int,
        homeScore: Int,
        awayTeam: TeamSummary? = nil,
        homeTeam: TeamSummary? = nil,
        baseOccupancy: BaseOccupancy? = nil,
        currentBatter: PlayerSummary? = nil,
        currentPitcher: PlayerSummary? = nil,
        awayLineUp: [PlayerSummary] = [],
        homeLineUp: [PlayerSummary] = [],
        awayLineUpBench: [PlayerSummary] = [],
        homeLineUpBench: [PlayerSummary] = [],
        playByPlay: PlayByPlay? = nil
    ) {
        self.id = id
        self.inningsNumber = inningsNumber
        self.isBottom = isBottom
        self.outs = outs
        self.strikes = strikes
        self.balls = balls
        self.awayScore = awayScore
        self.homeScore = homeScore
        self.awayTeam = awayTeam
        self.homeTeam = homeTeam
        self.baseOccupancy = baseOccupancy
        self.currentBatter = currentBatter
        self.currentPitcher = currentPitcher
        self.awayLineUp = awayLineUp
        self.homeLineUp = homeLineUp
        self.awayLineUpBench = awayLineUpBench
        self.homeLineUpBench = homeLineUpBench
        self.playByPlay = playByPlay
    }
}

@Model
final class TeamSummary: Identifiable {
    @Attribute(.unique) var id: UUID
    var currentBatterIndex: Int
    var outs: Int
    var teamId: Int
    var teamName: String
    var teamScore: Int

    init(id: UUID = UUID(), currentBatterIndex: Int, outs: Int, teamId: Int, teamName: String, teamScore: Int) {
        self.id = id
        self.currentBatterIndex = currentBatterIndex
        self.outs = outs
        self.teamId = teamId
        self.teamName = teamName
        self.teamScore = teamScore
    }
}

@Model
final class BaseOccupancy: Identifiable {
    @Attribute(.unique) var id: UUID
    @Relationship(deleteRule: .cascade) var firstBase: PlayerSummary?
    @Relationship(deleteRule: .cascade) var secondBase: PlayerSummary?
    @Relationship(deleteRule: .cascade) var thirdBase: PlayerSummary?

    init(id: UUID = UUID(), firstBase: PlayerSummary? = nil, secondBase: PlayerSummary? = nil, thirdBase: PlayerSummary? = nil) {
        self.id = id
        self.firstBase = firstBase
        self.secondBase = secondBase
        self.thirdBase = thirdBase
    }
}

@Model
final class PlayerSummary: Identifiable {
    @Attribute(.unique) var id: UUID
    var atBats: Int
    var firstName: String
    var hits: Int
    var jerseyNumber: String
    var lastName: String
    var pitchesThrown: Int
    var playerId: Int
    var playerName: String
    var order: Int
    var positionId: String

    init(
        id: UUID = UUID(),
        atBats: Int,
        firstName: String,
        hits: Int,
        jerseyNumber: String,
        lastName: String,
        pitchesThrown: Int,
        playerId: Int,
        playerName: String,
        order: Int,
        positionId: String
    ) {
        self.id = id
        self.atBats = atBats
        self.firstName = firstName
        self.hits = hits
        self.jerseyNumber = jerseyNumber
        self.lastName = lastName
        self.pitchesThrown = pitchesThrown
        self.playerId = playerId
        self.playerName = playerName
        self.order = order
        self.positionId = positionId
    }
}

@Model
final class PlayByPlay: Identifiable {
    @Attribute(.unique) var id: UUID
    var batterId: Int
    var batterName: String
    var mainEvent: String
    var mainMessage: String
    @Relationship(deleteRule: .cascade) var plays: [Play]

    init(id: UUID = UUID(), batterId: Int, batterName: String, mainEvent: String, mainMessage: String, plays: [Play] = []) {
        self.id = id
        self.batterId = batterId
        self.batterName = batterName
        self.mainEvent = mainEvent
        self.mainMessage = mainMessage
        self.plays = plays
    }
}

@Model
final class Play: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var message: String
    var fielder: String?

    init(id: UUID = UUID(), name: String, message: String, fielder: String? = nil) {
        self.id = id
        self.name = name
        self.message = message
        self.fielder = fielder
    }
}

// MARK: - Codable DTOs mirroring JSON and model mapping
struct GamecastDTO: Codable {
    var mainEvent: String
    var mainEventAction: String
    var createdByUserId: Int
    var teamGameId: Int
    var gameId: Int
    var teamId: Int
    var pitchData: PitchDataDTO?
    var scoring: ScoringDTO?
}

struct PitchDataDTO: Codable {
    var actionId: String
    var currentPitcher: Int
    var currentBatter: Int
    var fielderInvolved: [FielderInvolvedDTO]?
    var safeOrOut: SafeOrOutDTO?
}

struct FielderInvolvedDTO: Codable {
    var fieldedByPlayerId: Int
    var fieldedHitPoint: PointDTO?
}

struct PointDTO: Codable { var x: Double; var y: Double }

struct SafeOrOutDTO: Codable {
    var batter: PlayerRemovalDTO?
    var runners: [PlayerRemovalDTO]?
}

struct PlayerRemovalDTO: Codable {
    var id: Int
    var name: String
    var onWhichBasePlayerRemoved: String
    var status: String
}

struct ScoringDTO: Codable {
    var inningsNumber: Int
    var isBottom: Bool
    var outs: Int
    var strikes: Int
    var balls: Int
    var awayScore: Int
    var homeScore: Int
    var awayTeam: TeamSummaryDTO?
    var homeTeam: TeamSummaryDTO?
    var baseOccupancy: BaseOccupancyDTO?
    var currentBatter: PlayerSummaryDTO?
    var currentPitcher: PlayerSummaryDTO?
    var awayLineUp: [PlayerSummaryDTO]?
    var homeLineUp: [PlayerSummaryDTO]?
    var awayLineUpBench: [PlayerSummaryDTO]?
    var homeLineUpBench: [PlayerSummaryDTO]?
    var playByPlay: PlayByPlayDTO?
}

struct TeamSummaryDTO: Codable {
    var currentBatterIndex: Int
    var outs: Int
    var teamId: Int
    var teamName: String
    var teamScore: Int
}

struct BaseOccupancyDTO: Codable {
    var firstBase: PlayerSummaryDTO?
    var secondBase: PlayerSummaryDTO?
    var thirdBase: PlayerSummaryDTO?
}

struct PlayerSummaryDTO: Codable {
    var atBats: Int
    var firstName: String
    var hits: Int
    var jerseyNumber: String
    var lastName: String
    var pitchesThrown: Int
    var playerId: Int
    var playerName: String
    var order: Int
    var positionId: String
}

struct PlayByPlayDTO: Codable {
    var batterId: Int
    var batterName: String
    var mainEvent: String
    var mainMessage: String
    var plays: [PlayDTO]?
}

struct PlayDTO: Codable {
    var name: String
    var Message: String
    var fielder: String?
}

// MARK: - Mapping between DTOs and SwiftData models

extension GamecastDTO {
    init(model: Gamecast) {
        self.mainEvent = model.mainEvent
        self.mainEventAction = model.mainEventAction
        self.createdByUserId = model.createdByUserId
        self.teamGameId = model.teamGameId
        self.gameId = model.gameId
        self.teamId = model.teamId
        self.pitchData = model.pitchData.map { PitchDataDTO(model: $0) }
        self.scoring = model.scoring.map { ScoringDTO(model: $0) }
    }

    func toModel() -> Gamecast {
        let gc = Gamecast(
            mainEvent: mainEvent,
            mainEventAction: mainEventAction,
            createdByUserId: createdByUserId,
            teamGameId: teamGameId,
            gameId: gameId,
            teamId: teamId
        )
        if let pd = pitchData?.toModel() { gc.pitchData = pd }
        if let sc = scoring?.toModel() { gc.scoring = sc }
        return gc
    }
}

extension PitchDataDTO {
    init(model: PitchData) {
        self.actionId = model.actionId
        self.currentPitcher = model.currentPitcher
        self.currentBatter = model.currentBatter
        self.fielderInvolved = model.fielderInvolved.map { FielderInvolvedDTO(model: $0) }
        self.safeOrOut = model.safeOrOut.map { SafeOrOutDTO(model: $0) }
    }
    func toModel() -> PitchData {
        let m = PitchData(actionId: actionId, currentPitcher: currentPitcher, currentBatter: currentBatter)
        if let fi = fielderInvolved?.map({ $0.toModel() }) { m.fielderInvolved = fi }
        m.safeOrOut = safeOrOut?.toModel()
        return m
    }
}

extension FielderInvolvedDTO {
    init(model: FielderInvolved) {
        self.fieldedByPlayerId = model.fieldedByPlayerId
        self.fieldedHitPoint = model.fieldedHitPoint.map { PointDTO(model: $0) }
    }
    func toModel() -> FielderInvolved {
        FielderInvolved(fieldedByPlayerId: fieldedByPlayerId, fieldedHitPoint: fieldedHitPoint?.toModel())
    }
}

extension PointDTO {
    init(model: Point) { self.x = model.x; self.y = model.y }
    func toModel() -> Point { Point(x: x, y: y) }
}

extension SafeOrOutDTO {
    init(model: SafeOrOut) {
        self.batter = model.batter.map { PlayerRemovalDTO(model: $0) }
        self.runners = model.runners.map { PlayerRemovalDTO(model: $0) }
    }
    func toModel() -> SafeOrOut {
        let m = SafeOrOut()
        m.batter = batter?.toModel()
        if let r = runners?.map({ $0.toModel() }) { m.runners = r }
        return m
    }
}

extension PlayerRemovalDTO {
    init(model: PlayerRemoval) {
        self.id = model.playerId
        self.name = model.name
        self.onWhichBasePlayerRemoved = model.onWhichBasePlayerRemoved
        self.status = model.status
    }
    func toModel() -> PlayerRemoval {
        PlayerRemoval(playerId: id, name: name, onWhichBasePlayerRemoved: onWhichBasePlayerRemoved, status: status)
    }
}

extension ScoringDTO {
    init(model: Scoring) {
        self.inningsNumber = model.inningsNumber
        self.isBottom = model.isBottom
        self.outs = model.outs
        self.strikes = model.strikes
        self.balls = model.balls
        self.awayScore = model.awayScore
        self.homeScore = model.homeScore
        self.awayTeam = model.awayTeam.map { TeamSummaryDTO(model: $0) }
        self.homeTeam = model.homeTeam.map { TeamSummaryDTO(model: $0) }
        self.baseOccupancy = model.baseOccupancy.map { BaseOccupancyDTO(model: $0) }
        self.currentBatter = model.currentBatter.map { PlayerSummaryDTO(model: $0) }
        self.currentPitcher = model.currentPitcher.map { PlayerSummaryDTO(model: $0) }
        self.awayLineUp = model.awayLineUp.map { PlayerSummaryDTO(model: $0) }
        self.homeLineUp = model.homeLineUp.map { PlayerSummaryDTO(model: $0) }
        self.awayLineUpBench = model.awayLineUpBench.map { PlayerSummaryDTO(model: $0) }
        self.homeLineUpBench = model.homeLineUpBench.map { PlayerSummaryDTO(model: $0) }
        self.playByPlay = model.playByPlay.map { PlayByPlayDTO(model: $0) }
    }
    func toModel() -> Scoring {
        let m = Scoring(
            inningsNumber: inningsNumber,
            isBottom: isBottom,
            outs: outs,
            strikes: strikes,
            balls: balls,
            awayScore: awayScore,
            homeScore: homeScore
        )
        m.awayTeam = awayTeam?.toModel()
        m.homeTeam = homeTeam?.toModel()
        m.baseOccupancy = baseOccupancy?.toModel()
        m.currentBatter = currentBatter?.toModel()
        m.currentPitcher = currentPitcher?.toModel()
        if let a = awayLineUp?.map({ $0.toModel() }) { m.awayLineUp = a }
        if let h = homeLineUp?.map({ $0.toModel() }) { m.homeLineUp = h }
        if let ab = awayLineUpBench?.map({ $0.toModel() }) { m.awayLineUpBench = ab }
        if let hb = homeLineUpBench?.map({ $0.toModel() }) { m.homeLineUpBench = hb }
        m.playByPlay = playByPlay?.toModel()
        return m
    }
}

extension TeamSummaryDTO {
    init(model: TeamSummary) {
        self.currentBatterIndex = model.currentBatterIndex
        self.outs = model.outs
        self.teamId = model.teamId
        self.teamName = model.teamName
        self.teamScore = model.teamScore
    }
    func toModel() -> TeamSummary {
        TeamSummary(currentBatterIndex: currentBatterIndex, outs: outs, teamId: teamId, teamName: teamName, teamScore: teamScore)
    }
}

extension BaseOccupancyDTO {
    init(model: BaseOccupancy) {
        self.firstBase = model.firstBase.map { PlayerSummaryDTO(model: $0) }
        self.secondBase = model.secondBase.map { PlayerSummaryDTO(model: $0) }
        self.thirdBase = model.thirdBase.map { PlayerSummaryDTO(model: $0) }
    }
    func toModel() -> BaseOccupancy {
        BaseOccupancy(firstBase: firstBase?.toModel(), secondBase: secondBase?.toModel(), thirdBase: thirdBase?.toModel())
    }
}

extension PlayerSummaryDTO {
    init(model: PlayerSummary) {
        self.atBats = model.atBats
        self.firstName = model.firstName
        self.hits = model.hits
        self.jerseyNumber = model.jerseyNumber
        self.lastName = model.lastName
        self.pitchesThrown = model.pitchesThrown
        self.playerId = model.playerId
        self.playerName = model.playerName
        self.order = model.order
        self.positionId = model.positionId
    }
    func toModel() -> PlayerSummary {
        PlayerSummary(
            atBats: atBats,
            firstName: firstName,
            hits: hits,
            jerseyNumber: jerseyNumber,
            lastName: lastName,
            pitchesThrown: pitchesThrown,
            playerId: playerId,
            playerName: playerName,
            order: order,
            positionId: positionId
        )
    }
}

extension PlayByPlayDTO {
    init(model: PlayByPlay) {
        self.batterId = model.batterId
        self.batterName = model.batterName
        self.mainEvent = model.mainEvent
        self.mainMessage = model.mainMessage
        self.plays = model.plays.map { PlayDTO(model: $0) }
    }
    func toModel() -> PlayByPlay {
        let m = PlayByPlay(batterId: batterId, batterName: batterName, mainEvent: mainEvent, mainMessage: mainMessage)
        if let p = plays?.map({ $0.toModel() }) { m.plays = p }
        return m
    }
}

extension PlayDTO {
    init(model: Play) {
        self.name = model.name
        self.Message = model.message
        self.fielder = model.fielder
    }
    func toModel() -> Play { Play(name: name, message: Message, fielder: fielder) }
}

// MARK: - Codable helpers

enum GamecastCodable {
    static func decode(from data: Data) throws -> GamecastDTO {
        try JSONDecoder().decode(GamecastDTO.self, from: data)
    }
    static func encode(_ dto: GamecastDTO) throws -> Data {
        try JSONEncoder().encode(dto)
    }
}

/*

do {
    let data = try Data(contentsOf: Bundle.main.url(forResource: "GameCast", withExtension: "json")!)
    let dto = try GamecastCodable.decode(from: data)
    let dbmodel = dto.toModel()
    // Optionally persist with SwiftData
    // context.insert(model); try context.save()
}catch{
    print(error)
}


 
let dto = GamecastDTO(model: dbModel)
let data = try GamecastCodable.encode(dto)
// Write data to disk or send over network

*/

