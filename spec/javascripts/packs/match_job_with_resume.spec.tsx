import * as React from 'react'
import '../setupTests'
import { mount } from 'enzyme'
import moxios from 'moxios'
import {
  Data,
  ErrorMessage,
  GetStars,
  MatchJobWithResume,
  ResultObserver
} from '../../../app/javascript/packs/match_job_with_resume'

describe('MatchJobWithResume component', () => {
  describe('when retrieves successfully the stars from the backend', () => {
    it('displays the stars', () => {
      window.confirm = (_: string): boolean => {
        return true
      }
      const stubGetStars = function (jobId: string, jobSeekerId: string, observer: ResultObserver<Data>) {
        observer.success({ stars_html: 'some stars' })
      }

      const wrapper = mount<MatchJobWithResume>(<MatchJobWithResume jobId='10' jobSeekerId='33'
        getStars={stubGetStars} />)
      expect(wrapper.text()).toContain('Match against my Résumé')
      wrapper.find('a').simulate('click')
      expect(wrapper.find('.modal-body').text()).toContain('some stars')
    })
  })
})

describe('GetStars', () => {
  beforeEach(function () {
    moxios.install()
  })

  afterEach(function () {
    moxios.uninstall()
  })

  describe('when response is successful', () => {
    it('should ', (done) => {
      moxios.wait(() => {
        const request = moxios.requests.mostRecent()
        expect(request.url).toBe(`/jobs/20/match_resume?job_seeker_id=3`)
        request.respondWith({ status: 200, response: { stars_html: 'some result' } })
      })

      GetStars('20', '3', {
        success (data: Data) {
          expect(data.stars_html).toBe('some result')
          done()
        },
        error (_: ErrorMessage) {
          fail('should not get here')
        }
      })
    })
  })

  describe('when response is an error', () => {
    it('should ', (done) => {
      moxios.wait(() => {
        const request = moxios.requests.mostRecent()
        expect(request.url).toBe(`/jobs/20/match_resume?job_seeker_id=3`)
        request.respondWith({ status: 500, response: { error: 'some error' } })
      })

      GetStars('20', '3', {
        success (_: Data) {
          fail('should not get here')
        },
        error (_: ErrorMessage) {
          done()
        }
      })
    })
  })
})
